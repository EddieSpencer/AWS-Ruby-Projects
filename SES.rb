#!/usr/bin/env ruby
require 'rubygems'
require 'aws-sdk'

#AWS Credentials
ses = AWS::S3.new(
  :access_key_id => ENV['AMAZON_ACCESS_KEY_ID'],
    :secret_access_key => ENV['AMAZON_SECRET_ACCESS_KEY']
)

#returning verified email addresses
puts "Verified Email List: "
for email_addresses in ses.email_addresses
  puts email_addresses
end

#prompt for email recipient
print "Enter Email Recipient:"
recipient = gets
recipient.chomp!
puts "Sending Email to #{recipient}..."

ses.send_email(
  :subject => 'Hello from SES!',
  :from => 'spencee1@tcnj.edu',
  :to => recipient,
  :body_text => "Greetings #{recipient}, from Amazon SES!")

puts "Email Sent!"
name = gets
name.chomp!

#output quota and statistics
puts "Current Quotas:"
puts ses.quotas
puts ""
puts "Statistics:"
ses.statistics.each do |stats|
  puts "Sent: #{stats[:sent]}"
  puts "Delivery Attempts: #{stats[:delivery_attempts]}"
  puts "Rejects: #{stats[:rejects]}"
  puts "Bounces: #{stats[:bounces]}"
  puts "Complaints: #{stats[:complaints]}"
  puts
end
puts ""
name = gets
name.chomp!

#adding cc and bcc
print "Enter Email Recipient:"
recipient = gets
recipient.chomp!
print "Enter CC Email Recipients:"
ccString = gets
ccString.chomp!
print "Enter BCC Email Recipients:"
bccString = gets
bccString.chomp!
ccArray = ccString.split
bccArray = bccString.split


puts "Sending Email to all Recipients..."

ses.send_email(
  :subject => 'Hello from SES!',
  :from => 'spencee1@tcnj.edu',
  :to => recipient,
  :cc => ccArray,
  :bcc => bccArray,
  :body_text => "Greetings #{recipient}, from Amazon SES!")

puts "Email Sent!"
name = gets
name.chomp!
puts ""

#verifying email addresses
print "Enter an email to be verified:"
verif = gets
verif.chomp!
identity = ses.identities.verify(verif)
puts "Waiting for Email Verificiation..."
name = gets
name.chomp!
if identity.verified? == true
  puts "Email Verified!"
end
if identity.verified? == false
  puts "Email not Verified."
end

puts ""
name = gets
name.chomp!

#delete emails
print "Enter an Email Address to be Removed:"
removed = gets
removed.chomp!

ses.email_addresses.delete(removed)
puts "Email Deleted!"
puts ""
name = gets
name.chomp!
puts "Verified Email List: "
for email_addresses in ses.email_addresses
  puts email_addresses
end


