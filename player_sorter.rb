require "csv"
require_relative "player_filter"

class PlayerSorter
  attr_reader :file, :players, :teams, :to_result, :current_player, :filter, :filter_value

  KEYS = ["playerID", "yearID", "stint", "Team name(s)", "Batting Average"].freeze
  PLAYER_ID_COL = 0
  YEAR_COL = 1
  STINT_COL = 2
  TEAM_ID_COL = 3
  AB_COL = 6
  H_COL = 8

  def initialize(params, teams)
    @file = params.first
    @filter = params[1]&.strip
    @filter_value = params[2]&.strip
    @teams = teams

    @players = {}
    @current_player = {}
    @to_result = []
  end

  def run
    begin
      CSV.foreach(file, headers: true) do |player|
        initialize_player(player)

        next if PlayerFilter.new(filter, filter_value, current_player).deleted_by_filter?
        next if updated_player?

        save_player
      end
    rescue
      p "Please send correct file path"
      exit
    end

    push_to_result_array

    to_result.sort_by { |player| player["Batting Average"] }
  end

  private

  def initialize_player(player)
    current_player[:id] = player[PLAYER_ID_COL]
    current_player[:year] = player[YEAR_COL]
    current_player[:stint] = player[STINT_COL].to_i
    current_player[:ba] = calculate_ba(player[H_COL].to_f, player[AB_COL].to_f)
    current_player[:team_name] = teams[player[TEAM_ID_COL]]
  end

  def calculate_ba(h, ab)
    return 0 if h.zero? || ab.zero?

    (h / ab).round(3)
  end

  def updated_player?
    return false unless current_player[:stint] > 1 && players[id] && players[id][year]

    update_player
    true
  end

  def save_player
    player_hash = Hash[KEYS.zip([id, year, 1, team_name, ba])]
    player_year = { year => player_hash }
    players[id] ? players[id].merge!(player_year) : players[id] = player_year
  end

  def update_player
    current_ba = players[id][year]["Batting Average"]
    calculated_new_ba = (current_ba * players[id][year]["stint"] + ba) / (players[id][year]["stint"] + 1)
    players[id][year]["Team name(s)"] = players[id][year]["Team name(s)"] + ", " + team_name
    players[id][year]["Batting Average"] = calculated_new_ba.round(3)
    players[id][year]["stint"] = players[id][year]["stint"] + 1
  end

  def id
    current_player[:id]
  end

  def year
    current_player[:year]
  end

  def ba
    current_player[:ba]
  end

  def team_name
    current_player[:team_name]
  end

  def push_to_result_array
    players.each do |id, player_year|
      player_year.each { |year, player| to_result << player }
    end
  end
end
