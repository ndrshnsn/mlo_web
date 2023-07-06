require 'csv'

puts "Starting to seed..."
puts "--------------------"

puts "Initial Tasks"
DbSeederJob.perform_now
puts "--------------------"

puts "Seeding Countries"
countries_file = File.read(Rails.root.join('lib', 'seeds', 'nationalities.csv'))
countries = CSV.parse(countries_file, headers: true)
countries.each do |row|
    t = DefCountry.new
    t.name = row["name"]
    t.alias = row["alias"]
    t.save
    puts "Country #{t.name} added"
end
puts "--------------------"

puts "Seeding Teams"
teams_file = File.read(Rails.root.join('lib', 'seeds', 'teams.csv'))
teams = CSV.parse(teams_file, headers: true)
teams.each do |row|
    t = DefTeam.new
    t.name = row["name"].upcase
    t.nation = row["nation"]
    t.details = JSON.parse(row["details"])
    t.alias = row["alias"].upcase
    t.def_country_id = DefCountry.find_by(name: row["def_country"]).id
    t.platforms = row["platforms"].split(",")
    t.active = row["active"]
    t.save
    puts "Team #{t.name} added"
end
puts "Creating Team Slugs"
DefTeam.find_each(&:save)
puts "--------------------"

puts "seeding done!"