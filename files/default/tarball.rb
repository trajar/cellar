#!/usr/bin/env ruby

require 'rubygems'
require 'rake'
require 'optparse'

options = {}
options[:verbose] = false
options[:tarball_dir] = nil
options[:output_dir] = '.'
options[:format] = 'backup-%Y%m%d%H%M%S.tar.gz'

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
    options[:tarball_dir] = v
  end
  opts.on('-o', '--output STR') do |v|
    options[:output_dir] = v
  end
  opts.on('-f', '--format STR') do |v|
    options[:format] = v
  end
end.parse!

# compress directory to tarball
if options[:tarball_dir].nil?
  raise 'Directory not specified.'
end
unless Dir.exists? options[:tarball_dir]
  raise "Unable to locate directory [#{options[:tarball_dir]}]."
end
sh "tar -czf #{options[:output_dir]}/#{::Time.now.strftime(options[:format])} -C / #{options[:tarball_dir]}"
