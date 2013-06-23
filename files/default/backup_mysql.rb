#!/usr/bin/env ruby

require 'tempfile'
require_relative 'cellar'

# parse options
opts = Cellar::Options.new 'backup_mysql.rb'
opts.add(:database, '-d', '--database STR')
opts.add(:host, '-h', '--host STR')
opts.add(:user, '-u', '--user STR')
opts.add(:password, '-p', '--password STR')
opts.add(:file_name, '-n', '--name STR')
opts.add(:options, '-o', '--options STR')
opts.add(:mysqldump, '-c', '--mysqldump STR')
opts.parse

# set defaults
host_name = opts[:file_name] || 'localhost'
file_name = opts[:file_name] || 'backup-%Y%m%d%H%M%S.gz'
dump_options = opts[:options] || '--opt --comments --create-options --default-character-set=utf8mb4 --dump-date --hex-blob --quick --order-by-primary --add-drop-database --add-drop-table'
file_name = ::Time.now.strftime(file_name)

raise 'Database not specified.' unless opts[:database]

# build dump command
mysqldump = opts[:mysqldump] || 'mysqldump'
mysqldump = "#{mysqldump} --databases #{opts[:database]} --host=#{host_name}"
if opts[:user]
  mysqldump = "#{mysqldump} --user=#{opts[:user]}"
end
if opts[:password]
  mysqldump = "#{mysqldump} --password=#{opts[:password]}"
end
if opts[:verbose]
  mysqldump = "#{mysqldump} --verbose"
end
mysqldump = "#{mysqldump} #{dump_options}"

tmp_file = Tempfile.new(['mysqldump', '.tar.gz'])
tmp_file.close
begin
  # compress directory to tarball
  Cellar.logger.debug "Compressing mysql database [#{opts[:database]}] to [#{tmp_file.path}] ..."
  verbose_flag = opts[:verbose] ? 'v' : ''
  sh "#{mysqldump} | gzip --best -c#{verbose_flag} > #{tmp_file.path}"
  # cleanup
  Cellar::Uploader.new(opts).upload_file tmp_file, file_name
  Cellar::Cleaner.new(opts).cleanup_bucket if opts[:pattern]
ensure
  tmp_file.unlink
end

