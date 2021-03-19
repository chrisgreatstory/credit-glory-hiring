class PrintResult
  attr_reader :players

  COL_LABELS = ["playerID", "yearID", "Team name(s)", "Batting Average"].freeze

  def initialize(players)
    @players = players
  end

  def run
    write_divider
    write_header
    write_divider
    players.each { |h| write_line(h) }
    write_divider
  end

  private

  def write_header
    puts "| #{ columns.map { |_,g| g[:label].ljust(g[:width]) }.join(' | ') } |"
  end

  def write_divider
    puts "+-#{ columns.map { |_,g| "-"*g[:width] }.join("-+-") }-+"
  end

  def write_line(h)
    str = COL_LABELS.map { |k| h[k].to_s.ljust(columns[k][:width]) }.join(" | ")
    puts "| #{str} |"
  end

  def columns
    @_columns ||= COL_LABELS.each_with_object({}) do |col, h|
      value_max_length = players.map { |g| g[col].to_s.size }.max || 0
      h[col] = { label: col, width: [value_max_length, col.size].max }
    end
  end
end
