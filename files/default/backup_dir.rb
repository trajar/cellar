#!/usr/bin/env ruby

require 'tempfile'
require_relative 'cellar'

# parse options
opts = Cellar::Options.new 'backup_dir.rb'
opts.add(:dir, '-d', '--dir STR')
opts.add(:file_name, '-n', '--name STR')
opts.parse

# set defaults
file_name = opts[:file_name] || 'backup-%Y%m%d%H%M%S.tar.gz'
file_name = ::Time.now.strftime(file_name)
dir_name = opts[:dir] || '.'

raise "Unable to locate directory [#{dir_name}]." unless File.directory?(dir_name)

tmp_file = Tempfile.new(['backup', '.tar.gz'])
begin
  # compress directory to tarball
  Cellar.logger.debug "Compressing [#{dir_name}] to [#{tmp_file.path}] ..."
  verbose_flag = opts[:verbose] ? 'v' : ''
  system "tar -cpz#{verbose_flag}f #{file_name} -C #{dir_name} ."
  # cleanup
  Cellar::Uploader.new(opts).upload_file file_name
  Cellar::Cleaner.new(opts).cleanup_bucket if opts[:pattern]
ensure
  tmp_file.close
  tmp_file.unlink
end

