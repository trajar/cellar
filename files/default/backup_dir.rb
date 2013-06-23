#!/usr/bin/env ruby

require 'tempfile'
require 'tmpdir'
require_relative 'cellar'

# parse options
opts = Cellar::Options.new 'backup_dir.rb'
opts.add(:dir, '-d', '--dir STR')
opts.add(:file_name, '-n', '--name STR')
opts.add(:exclude, '-e', '--exclude STR')
opts.parse

# set defaults
file_name = opts[:file_name] || 'backup-%Y%m%d%H%M%S.tar.gz'
file_name = ::Time.now.strftime(file_name)
dir_name = opts[:dir] || '.'
exclude = opts[:exclude] || ''

raise "Unable to locate directory [#{dir_name}]." unless File.directory?(dir_name)

tmp_file = File.join Dir.tmpdir, "#{opts[:bucket]}.#{file_name}"
begin
  # compress directory to tarball
  Cellar.logger.debug "Compressing [#{dir_name}] to [#{tmp_file}] ..."
  verbose_flag = opts[:verbose] ? 'v' : ''
  excludes = ''
  exclude.split(',').each do |exlude_pattern|
    excludes = "#{excludes} --exclude='#{exlude_pattern}'"
  end
  system "tar -cpz#{verbose_flag}f #{tmp_file} #{excludes} -C #{dir_name} ."
  # cleanup
  Cellar::Uploader.new(opts).upload_file tmp_file, file_name
  Cellar::Cleaner.new(opts).cleanup_bucket if opts[:pattern]
ensure
  File.delete(tmp_file) if File.exists?(tmp_file)
end

