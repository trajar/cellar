#!/usr/bin/env ruby

require 'rubygems'
require 'rake'
require 'optparse'
require 'aws-sdk'

options = {}
options[:verbose] = false
options[:access_key_id] = nil
options[:secret_access_key] = nil
options[:bucket] = nil
options[:backup_dir] = nil
options[:keep] = 5
options[:remove_local] = true

# parse options
OptionParser.new do |opts|
  opts.banner = 'Usage: backup.rb [options]'
  opts.on( '-h', '--help') do
    puts opts
    exit
  end
  opts.on('-v', '--[no-]verbose') do |v|
    options[:verbose] = v
  end
  opts.on('-k', '--key STR') do |v|
    options[:access_key_id] = v
  end
  opts.on('-s', '--secret STR') do |v|
    options[:secret_access_key] = v
  end
  opts.on('-b', '--bucket STR') do |v|
    options[:bucket] = v
  end
  opts.on('-d', '--dir STR') do |v|
    options[:backup_dir] = v
  end
  opts.on('-k', '--keep NUM') do |v|
    options[:keep] = v.to_i
  end
  opts.on('-r', '--[no-]remove') do |v|
    options[:remove_local] = v
  end
end.parse!

# set aws-s3 connection
s3 = AWS::S3.new(:access_key_id => options[:access_key_id], :secret_access_key => options[:secret_access_key])
bucket = s3.buckets[options[:bucket]]
if bucket.nil? || !bucket.exists?
  raise "Unable to locate aws bucket [#{options[:bucket]}]."
end

# grab all backup tarballs
tarballs = FileList.new(options[:backup_dir] + '/*.tar.gz')
if options[:backup_dir].nil? || !Dir.exists?(options[:backup_dir])
  raise "Unable to locate backup directory [#{options[:backup_dir]}]."
end
if tarballs.empty?
  puts "Did no locate any backup tarballs in [#{options[:backup_dir]}]."
end

# upload known backup files
tarballs.each do |tarball|
  basename = File.basename tarball
  obj = bucket.objects[basename]
  if obj.exists?
    puts "Backup file [#{basename}] already exists." if options[:verbose]
  else
    puts "Uploading backup file [#{basename}] to aws-s3 ..."
    obj = bucket.objects[basename]
    obj.write(:file => tarball)
    sleep 1
  end
  File.delete tarball if options[:remove_local]
end

# read all backup files, keeping only the most recent
if options[:keep] > 0
  items = Array.new
  bucket.objects.each do |obj|
    items.push obj if obj.key.end_with? '.tar.gz'
  end
  if options[:verbose]
    items.each do |item|
      puts "Backup backup file [#{item.key}] available - last updated #{item.last_modified}."
    end
  end
  items.sort! { |a,b| b.last_modified <=> a.last_modified }
  if items.size > options[:keep]
    old_items = items[options[:keep]-1, items.size]
    old_items.reverse!.each do |item|
      puts "Removing old backup file [#{item.key}] from aws-s3 ..."
      item.delete
    end
  end
end