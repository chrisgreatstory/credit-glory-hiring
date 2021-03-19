require "csv"
require_relative "player_sorter"
require_relative "print_result"

params = ARGV

EMPTY_MESSAGE = "Please send params. We expect first param (csv file name), second - one of filters "\
  "(year, team name, year and team name), third - filter values separated by comma, "\
  "e.g ('file_name.csv', 'year and team name', '1873, Philadelphia Athletics')"
TEAM_ID_COL = 2
TEAM_NAME_COL = 11

teams = {}

if params.empty?
  p EMPTY_MESSAGE
  exit
end

p "Processing...."

CSV.foreach("Teams.csv", headers: true) { |team| teams[team[TEAM_ID_COL]] = team[TEAM_NAME_COL] }

sorted_players = PlayerSorter.new(params, teams).run

PrintResult.new(sorted_players).run
