# hiring-exercises
# language
ruby

# run
* ruby main.rb "path_to_file" "filter" "filter_value"
* filters: ["year", "team name", "year and team name"]
* filter_value - for "year and team name" filter is string separated by comma

e.g.:

```ruby
ruby main.rb "Batting.csv" "year and team name" "2015, New York Highlanders "
ruby main.rb "/home/chris/Work/hiring-exercises/Batting.csv" "team name" "New York Highlanders "
```
