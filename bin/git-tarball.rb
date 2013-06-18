#!/usr/bin/env ruby

require 'rubygems'
require 'rake'
require 'optparse'

options = {}
options[:verbose] = false
options[:git_dir] = nil
options[:output_dir] = '.'
options[:format] = 'git-%Y%m%d%H%M%S'

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
  opts.on('-d', '--dir STR') do |v|
    options[:git_dir] = v
  end
  opts.on('-o', '--output STR') do |v|
    options[:output_dir] = v
  end
  opts.on('-f', '--format STR') do |v|
    options[:format] = v
  end
end.parse!

# dump git directory to tarball
if options[:git_dir].nil?
  raise 'Directory not specified.'
end
unless Dir.exists? options[:git_dir]
  raise "Unable to locate directory [#{options[:bucket]}]."
end
sh "tar -cvzf #{options[:output_dir]}/#{::Time.now.strftime(options[:format])}.tar.gz #{options[:git_dir]}"
