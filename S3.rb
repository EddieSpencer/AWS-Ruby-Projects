#!/usr/bin/env ruby
require 'rubygems'
require 'aws-sdk'

#AWS Credentials
s3 = AWS::S3.new(
  :access_key_id => 'AKIAIBWAOGCWCPIS6X4A',
  :secret_access_key => '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'
)

#clears buckets for demo purpose
for bucket in s3.buckets
   bucket.delete!
end

puts "Creating Bucket..."
#creating a bucket
s3.buckets.create('eddiebucket21')

#bucket list
puts "Current Bucket List:"

for bucket in s3.buckets
  puts bucket.name
end

puts " "
name = gets
name.chomp!
#fetch bucket name
photo_bucket = s3.buckets['eddiebucket21']

#number of elements in bucket

puts "Adding Files to Bucket..."

#adding object to bucket
file = 'Mountain.jpg'
photo_bucket.objects[file].write(Pathname.new('Mountain.jpg'))

#see objects in bucket
photo_bucket.objects.each do |obj|
  puts obj.key
end
puts ""
name = gets
name.chomp!

puts "Getting object from bucket..."
#get object from bucket
File.open('downloaded.jpg', 'w') do |file|
  photo_bucket.objects['Mountain.jpg'].read do |chunk|
    file.write(chunk)
  end
end

puts ""
name = gets
name.chomp!

puts "Deleting object from bucket..."
#deleting object from bucket
photo_bucket.objects[file].delete
puts ""
name = gets
name.chomp!

puts "Adding Files to Bucket..."
#adding another file to bucket
file2 = 'Island.jpg'
photo_bucket.objects[file2].write(Pathname.new('Island.jpg'))
photo_bucket.objects.each do |obj|
  puts obj.key
end
puts ""
name = gets
name.chomp!

puts "Creating New Bucket..."
#creates new bucket
new_bucket = s3.buckets.create('thisbucketiseddies21')
puts ""
name = gets
name.chomp!

puts "Current Buckets"
#bucket list
for bucket in s3.buckets
  puts bucket.name
end

puts ""
name = gets
name.chomp!

puts "Deleting Empty Bucket..."
#delete empty bucket
new_bucket.delete
puts ""
name = gets
name.chomp!

puts "Current Buckets"
#bucket list
for bucket in s3.buckets
  puts bucket.name
end
puts ""
name = gets
name.chomp!

#determines if bucket exists / permission to access it (HEAD)
puts "Does a bucket exist?"
puts "Enter bucket name to check:"
bucketname = gets
bucketname.chomp!
bucket = s3.buckets[bucketname]
puts bucket.exists?
puts ""

#check permission
if (bucket.exists? == true)
puts "Checking Permissions..."
begin
  tester = s3.buckets[bucketname].acl
  puts "Permission Granted..."
rescue AWS::S3::Errors::AccessDenied => e
  puts "Permission Denied..."
end
end

puts ""
name = gets
name.chomp!

#copy obj from bucket to another
puts "Creating new Bucket..."
copy_bucket = s3.buckets.create('copybucket21')
puts ""
name = gets
name.chomp!

puts "Current Buckets"
#bucket list
for bucket in s3.buckets
  puts bucket.name
end

puts ""
name = gets
name.chomp!

puts "Copying object from one bucket to another..."
photo_bucket.objects['Island.jpg'].copy_to(copy_bucket.objects['Island_copy.jpg'])
puts ""
name = gets
name.chomp!

puts "Copied objects in bucket"
copy_bucket.objects.each do |obj|
  puts obj.key
end
puts ""
name = gets
name.chomp!

puts "Listing of All Buckets"
#bucket list
for bucket in s3.buckets
  puts bucket.name
end
#set exp date on obj
puts ""
name = gets
name.chomp!

#print exp date
puts "Setting Expiration Date..."
copy_bucket.lifecycle_configuration.update do
  add_rule('Island_copy.jpg', :expiration_time => 4)
end
object1 = copy_bucket.objects['Island_copy.jpg']
puts object1.expiration_date
puts ""
puts "Reduced Redundancy:"
puts object1.reduced_redundancy =(true)
puts ""
name = gets
name.chomp!

#put object versionin
puts "Enabling Object Versioning..."
version_bucket = s3.buckets.create('versionbucket21')
version_bucket.versioning_enabled? #=> false

version_bucket.enable_versioning

obj = version_bucket.objects['version.txt']
obj.write('a')
obj.write('b')
obj.delete
obj.write('c')
i = 0
obj.versions.each do |obj_version|
 i+=1
  print i.to_s + " "
 if obj_version.delete_marker?
     puts "- DELETE MARKER"
  else
     puts obj_version.read
  end
end
puts ""
name = gets
name.chomp!

#deleteing specific version
puts "Determine which version to delete..."
choice = gets
choice.chomp!
obj.versions.to_a[choice.to_i-1].delete
puts ""
name = gets
name.chomp!

puts "Current versioning..."
i = 0
obj.versions.each do |obj_version|
 i+=1
  print i.to_s + " "
 if obj_version.delete_marker?
     puts "- DELETE MARKER"
  else
     puts obj_version.read
  end
end
puts ""
name = gets
name.chomp!

#get meta data
puts "Retrieving meta-data..."
obj2 = copy_bucket.objects['Island_copy.jpg']
puts obj2.metadata
puts obj2.head.data

