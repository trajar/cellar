#!/usr/bin/env ruby

require_relative  'cellar'

# parse options
opts = Cellar::Options.new 'backup_files.rb'
opts.add(:backup_dir, '-d', '--dir STR')
opts.parse

# grab all backup tarballs
tarballs = FileList.new(opts[:backup_dir] + '/*.tar.gz')
if opts[:backup_dir].nil? || !Dir.exists?(opts[:backup_dir])
  raise "Unable to locate backup directory [#{opts[:backup_dir]}]."
end
if tarballs.empty?
  Cellar.logger.warn "Did no locate any backup tarballs in [#{opts[:backup_dir]}]."
end

# upload file, cleanup
Cellar::Uploader.new(opts).upload_files tarballs
Cellar::Cleaner.new(opts).cleanup_bucket if opts[:pattern]