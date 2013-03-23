#!/usr/bin/env_ruby
require 'rubygems'
require 'aws-sdk'

#AWS Credentials
sns = AWS::SNS.new(
  :access_key_id => 'AKIAIBWAOGCWCPIS6X4A',
  :secret_access_key => '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'
)

#deletes everything for demo
#for topics in sns.topics
 # topics.delete!
#end

#Create new Topics
puts "Creating new topics..."

alpha = sns.topics.create('CSC470Test-Alpha')
beta = sns.topics.create('CSC470Test-Beta')
puts
name = gets
name.chomp!

puts "List of topics:"
for topics in sns.topics
  puts topics.name
end
puts
name = gets
name.chomp!

puts "Deleteing topics..."
beta.delete
puts
name = gets
name.chomp!

puts "List of topics:"
for topics in sns.topics
  puts topics.name
end
puts
name = gets
name.chomp!

#adding subscriptions
#figure out error handling if already confirmed.
puts "Adding subscriptions..."
alpha.subscribe('http://cloud.comtor.org/csc470logger/logger')
#if(alpha.subscriptions.confirmation_authenticated? == false)
alpha.subscribe('eddiespencer121@gmail.com')
alpha.subscribe('peter.depasquale@gmail.com', :json => true)
#end
puts
name = gets
name.chomp!

puts "Topic attributes:"
sns.topics.each do |topics|
  puts "arn: #{topics.arn}"
  puts "owner: #{topics.owner}"
  puts "policy: #{topics.policy}"
  puts "name: #{topics.display_name}"
  puts "subscriptions confirmed: #{topics.num_subscriptions_confirmed}"
  puts
end

puts
name = gets
name.chomp!

#displaying subscriptions
#why delivery policy empty for email?
puts "List of subscriptions:"
sns.subscriptions.each do |subscriptions|
  puts "SubscriptionARN: #{subscriptions.arn}"
  puts "TopicARN: #{subscriptions.topic_arn}"
  puts "Owner: #{subscriptions.owner_id}"
  puts "Delivery Policy: #{subscriptions.delivery_policy_json}"
  puts
end


name = gets
name.chomp!

#publish message
puts "Enter message to publish to topic:"
message=gets
message.chomp!

alpha.publish(message,
              :http => "#{message}",
              :email => "#{message}")
puts
name = gets
name.chomp!

#cloud watch
puts "Creating CloudWatch alert..."
cw = AWS::CloudWatch.new(
  :access_key_id => 'AKIAIBWAOGCWCPIS6X4A',
  :secret_access_key => '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'

)

cw.alarms.create("alarm_name",
                 :namespace => 'AWS/Billing',
                 :comparison_operator => 'GreaterThanThreshold',
                 :dimensions => [{:name => "Currency", :value => "USD"}],
                 :metric_name => 'EstimatedCharges',
                 :evaluation_periods => 1,
                 :period => 86400,
                 :statistic => "Maximum",
                 :threshold => 2,
                 :alarm_actions => [alpha.arn]
                )



