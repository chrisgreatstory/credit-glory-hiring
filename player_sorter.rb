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

  teams = {}
  CSV.foreach('Teams.csv', headers: true) { |team| teams[team[2]] = team[11] }

  filter = params[1]&.strip
  filter_value = params[2]&.strip

  begin
    players = {}
    keys = ["playerID", "yearID", "stint", "Team name(s)", "Batting Average"]

    CSV.foreach(params.first, headers: true) do |row|
      id = row[0]
      year = row[1]
      stint = row[2].to_i
      ba = calculate_ba(row[8].to_f, row[6].to_f)
      team_name = teams[row[3]]

      if filter && filter_value
        next if filter_value != year && filter == "year"
        next if filter_value != team_name && filter == "team name"

        filtered_year = filter_value.split(',')[0]&.strip
        filtered_team_name = filter_value.split(',')[1]&.strip

        next if (filtered_year != year || filtered_team_name != team_name) && filter == "year and team name"
      end

      if stint > 1 && players[id] && players[id][year]
        current_ba = players[id][year]["Batting Average"]
        calculated_new_ba = (current_ba * players[id][year]["stint"] + ba) / (players[id][year]["stint"] + 1)
        players[id][year]["Team name(s)"] = players[id][year]["Team name(s)"] + ", " + team_name
        players[id][year]["Batting Average"] = calculated_new_ba.round(3)
        players[id][year]["stint"] = players[id][year]["stint"] + 1
        next
      end

      stint_hash = Hash[keys.zip([id, year, 1, team_name, ba])]
      player_year = { year => stint_hash }
      players[id] ? players[id].merge!(player_year) : players[id] = player_year
    end
  rescue
    p "Please send correct file path"
    exit
  end

  to_result = []
  players.each do |id, player_year|
    player_year.each { |year, player| to_result << player }
  end

  @columns = @col_labels.each_with_object({}) do |col, h|
    value_max_length = to_result.map { |g| g[col].to_s.size }.max || 0
    h[col] = { label: col, width: [value_max_length, col.size].max }
  end

  write_divider
  write_header
  write_divider
  to_result.sort_by { |player| player["Batting Average"] }.each { |h| write_line(h) }
  write_divider
end
player_sorter
