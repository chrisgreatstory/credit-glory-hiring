class PlayerFilter
  attr_reader :current_player, :filter, :filter_value

  def initialize(filter, filter_value, current_player)
    @filter = filter
    @filter_value = filter_value
    @current_player = current_player
  end

  def deleted_by_filter?
    (filter && filter_value) && (failed_by_year? || failed_by_name? || failed_by_any?)
  end

  private

  def failed_by_year?
    filter == "year" && filter_value != current_player[:year]
  end

  def failed_by_name?
    filter == "team name" && filter_value != current_player[:team_name]
  end

  def failed_by_any?
    filtered_year = filter_value.split(',')[0]&.strip
    filtered_team_name = filter_value.split(',')[1]&.strip
    year = current_player[:year]
    team_name = current_player[:team_name]

    filter == "year and team name" && (filtered_year != year || filtered_team_name != team_name)
  end
end
