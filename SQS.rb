#!/usr/bin/env_ruby
require 'rubygems'
require 'aws-sdk'

#AWS Credentials
sqs = AWS::SQS.new(
  :access_key_id => ENV['AMAZON_ACCESS_KEY_ID'],
    :secret_access_key => ENV['AMAZON_SECRET_ACCESS_KEY']
)

puts "Creating Queues.."

q1 = sqs.queues.create("csc470test")
q2 = sqs.queues.create("csc470test2")

puts
gets

puts "Fetching Attributes..."
for queue in sqs.queues
  puts "Creation Time: #{queue.created_timestamp}"
  puts "ARN: #{queue.arn}"
  puts "Message Retention Period: #{queue.message_retention_period}"
  puts "Last Modified: #{queue.last_modified_timestamp}"
  puts
end
gets

puts "List of Queues:"
puts sqs.queues.collect(&:url)
puts
gets

puts "Sending Messages..."
i = 1

while i < 4 do
msg = q1.send_message("test"+i.to_s)
puts "Sent message #{i} : #{msg.id}"
i+=1
end

puts
gets

puts "Deleting Queues..."
q2.delete
puts
gets

puts "Number of Messages in csc470test:"
puts q1.approximate_number_of_messages
puts
gets

puts "Receiving First Message From Queue.."

q1.receive_message :limit => 1 do |message|
  puts message.body
end
puts 
puts "Receiving remaining messages..."
q1.receive_message :limit => 1 do |message|
  puts message.body
end
q1.receive_message :limit => 1 do |message|
  puts message.body
end


puts
gets
puts "Deleting Queues..."
q1.delete
puts
