#!/usr/bin/env_ruby
require 'rubygems'
require 'aws-sdk'
require 'open-uri'
#AWS Credentials
dynamo_db = AWS::DynamoDB.new(
  :access_key_id => 'AKIAIBWAOGCWCPIS6X4A',
  :secret_access_key => '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'
)

puts "Deleting Tables..."
for tables in dynamo_db.tables
  tables.delete
end

#creating tables
puts "Creating two tables..."
name = gets
name.chomp!
table1 = dynamo_db.tables.create('table1',10,15,
    :hash_key => {:zipcode => :string} )
sleep 1 while table1.status == :creating
table2 = dynamo_db.tables.create('table2',10,15,
   :hash_key => {:city => :string},
  :range_key => {:zipcode => :string}
  )
sleep 1 while table2.status == :creating
#table1.provision_throughput :read_capacity_units => 1, :write_capacity_units => 1
#table2.provision_throughput :read_capacity_units => 1, :write_capacity_units => 1

puts "List of Tables:"
for tables in dynamo_db.tables
  puts tables.name
end

table1 = dynamo_db.tables['table1']
table1.load_schema
table2 = dynamo_db.tables['table2']
table2.load_schema
puts
name = gets
name.chomp!

#status, schemua, when created
puts "Description of Tables:"
for tables in dynamo_db.tables
  puts "Table Name: #{tables.name}"
  puts "Status: #{tables.status}"
  puts "Primary Schema: #{tables.load_schema}"
  puts "Hash Key: #{tables.hash_key ? tables.hash_key.name : 'None'}"
  puts "Range Key: #{tables.range_key ? tables.range_key.name : 'None'}"
  puts "Creation Time: #{tables.creation_date_time}"
  puts 
end
puts
name = gets
name.chomp!

#puts "Getting file from web.."
#open('zipcodes.txt', 'wb') do |file|
#  file << open('https://s3.amazonaws.com/depasquale/datasets/zipcodes.txt').read
#end
puts "Adding items to first table"
file = File.open("zipcodes.txt")
20.times do 
  line = file.readline
  line = line.delete('"').split(',')
  item = {
    :zipcode => line[0],
    :lat => line[1].to_f,
    :long => line[2].to_f,
    :city => line[3],
    :state => line[4],
    :street => line[5],
    :type => line[6]
  }

  table1.items.create(item)
end
puts
name = gets
name.chomp!

puts "Adding items to second table"
file = File.open("zipcodes.txt")
40.times do 
  line = file.readline
  line = line.delete('"').split(',')
  item = {
    :zipcode => line[0],
    :lat => line[1].to_f,
    :long => line[2].to_f,
    :city => line[3],
    :state => line[4],
    :street => line[5],
    :type => line[6]
  }

  table2.items.create(item)
end
puts
name = gets
name.chomp!

puts "Table1: Search Zipcodes greater than 00610"

items = table1.items.where(:zipcode).greater_than("00610")
puts items.count
for item in items
  item.attributes.each_value do |value|
    print value
    print " "
  end
puts 
end
puts
gets
puts "Table2: Search City greater than ARECIBO"
items = table2.items.where(:city).greater_than("ARECIBO")
puts items.count

for item in items
  item.attributes.each_value do |value|
    print value
    print " "
  end
puts 
end
puts
gets
puts "Table2: Query city equal to ARECIBO"
items = table2.items.query(:hash_value => 'ARECIBO')
puts items.count

for item in items
  item.attributes.each_value do |value|
    print value
    print " "
  end
puts 
end
puts
gets
puts "Enter item key (zipcode) to be deleted from Table1:"
destroy = gets
destroy.chomp!

item = table1.items.at(destroy)
item.delete
puts
gets

puts "Enter item keys (city and zipcode) to be deleted from Table2:"
destroy_city = gets
destroy_city.chomp!
destroy_zip = gets
destroy_zip.chomp!

item = table2.items.at(destroy_city, destroy_zip)
item.delete

puts
gets

puts "Enter key (zipcode) to search for in Table1"
key1 = gets
key1.chomp!
item = table1.items.at(key1)

puts "Which field will be changed:"
field = gets
field.chomp!

puts "Enter the replacement for #{field}:"
replace = gets
replace.chomp!

item.attributes.update do |u|
  u.set(field => replace)
end
puts
gets

puts "Enter keys (city and zipcode) to search for in Table2"
key1 = gets
key1.chomp!
key2 = gets
key2.chomp!
item = table2.items.at(key1,key2)

puts "Which field will be changed:"
field = gets
field.chomp!

puts "Enter the replacement for #{field}:"
replace = gets
replace.chomp!

item.attributes.update do |u|
  u.set(field => replace)
end
puts 
gets
puts "Changing Read and Write Capacity to 1:"
table1.provision_throughput :read_capacity_units => 1, :write_capacity_units => 1
table2.provision_throughput :read_capacity_units => 1, :write_capacity_units => 1
puts
gets
puts "Enter which Table to be deleted:"
table = gets
gets.chomp!

table.delete


