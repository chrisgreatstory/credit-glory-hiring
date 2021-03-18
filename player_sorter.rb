require 'csv'

def calculate_ba(h, ab)
  return 0 if h.zero? || ab.zero?

  (h / ab).round(3)
end

def write_header
  puts "| #{ @columns.map { |_,g| g[:label].ljust(g[:width]) }.join(' | ') } |"
end

def write_divider
  puts "+-#{ @columns.map { |_,g| "-"*g[:width] }.join("-+-") }-+"
end

def write_line(h)
  str = @col_labels.map { |k| h[k].to_s.ljust(@columns[k][:width]) }.join(" | ")
  puts "| #{str} |"
end

def player_sorter
  params = ARGV
  empty_message = "Please send params. We expect first param (csv file name), second - one of filters "\
    "(year, team name, year and team name), third - filter values separated by comma, "\
    "e.g ('file_name.csv', 'year and team name', '1873, Philadelphia Athletics')"
  @col_labels = ["playerID", "yearID", "Team name(s)", "Batting Average"]

  if params.empty?
    p empty_message
    exit
  end

  p "Processing...."

  teams = []
  CSV.foreach('Teams.csv', headers: true) do |team|
    keys = ["teamID", "name"]
    teams << Hash[keys.zip([team[2], team[11]])]
  end

  begin
    players = []
    keys = ["playerID", "yearID", "stint", "teamID", "AB", "H"]
    CSV.foreach(params.first, headers: true) do |row|
      player = Hash[keys.zip([row[0], row[1], row[2], row[3], row[6], row[8]])]
      team = teams.find { |team| team["teamID"] == player["teamID"] }
      player["Team name(s)"] = team["name"]
      player["Batting Average"] = calculate_ba(player["H"].to_f, player["AB"].to_f)

      players << player
    end
  rescue
    p "Please send correct file path"
    exit
  end

  filter = params[1]&.strip
  filter_value = params[2]&.strip
  if filter && filter_value
    case filter
    when "year"
      players.delete_if { |player|  player["yearID"] != filter_value }
    when "team name"
      players.delete_if { |player|  player["Team name(s)"].strip != filter_value }
    when "year and team name"
      year = filter_value.split(',')[0]&.strip
      team_name = filter_value.split(',')[1]&.strip
      players.delete_if { |player| (player["yearID"] != year) || (player["Team name(s)"].strip != team_name) }
    else
      p "Use correct filter name if you want to filter results"
    end
  end

  players.each do |player|
    next if player["stint"] == "1"

    stint_players = players.select { |h| h["yearID"] == player["yearID"] && h["playerID"] == player["playerID"] }
    ba_avg = (stint_players.map { |h| h["Batting Average"] }.sum) / stint_players.length
    player["Batting Average"] = ba_avg.round(3)
    player["Team name(s)"] = stint_players.map { |h| h["Team name(s)"] }.join(", ")

    players.delete_if { |h| h["yearID"] == player["yearID"] && h["playerID"] == player["playerID"] && h["stint"] != player["stint"] }
  end

  @columns = @col_labels.each_with_object({}) do |col, h|
    value_max_length = players.map { |g| g[col].to_s.size }.max || 0
    h[col] = { label: col, width: [value_max_length, col.size].max }
  end

  write_divider
  write_header
  write_divider
  players.sort_by { |player| player["Batting Average"] }.each { |h| write_line(h) }
  write_divider
end
player_sorter
