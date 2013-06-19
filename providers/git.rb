
action :backup do

  bucket = @new_resource.bucket
  access_key_id = @new_resource.access_key_id
  secret_access_key = @new_resource.secret_access_key
  backup_format = @new_resource.backup_format
  backup_dir = @new_resource.backup_dir
  git_dir = @new_resource.git_dir

  cron @new_resource.name do
    hour '3'
    minute '0'
    mailto 'quotediddly@gmail.com'
    action :create
    command "ruby #{node['cellar']['dir']}/tarball.rb --dir #{git_dir} --out #{backup_dir} --format #{backup_format} && ruby #{node['cellar']['dir']}/backup.rb --dir #{backup_dir} --bucket #{bucket} --key #{access_key_id} --secret #{secret_access_key} "
  end

end

action :restore do

  require 'rubygems'
  require 'rake'
  require 'aws-sdk'

  bucket = @new_resource.bucket
  access_key_id = @new_resource.access_key_id
  secret_access_key = @new_resource.secret_access_key
  git_dir = @new_resource.git_dir

  if @new_resource.backup.eql? :latest
    backup_name = latest_backup(bucket, access_key_id, secret_access_key)
  else
    backup_name = @new_resource.backup
  end

  if backup_name.nil? || backup_name.empty?
    return
  end

  s3_backup = ::File.join Chef::Config[:file_cache_path], backup_name

  unless ::File.exists? s3_backup
    s3_file s3_backup do
      source "s3://#{bucket}/#{backup_name}"
      access_key_id access_key_id
      secret_access_key secret_access_key
      owner 'root'
      mode 0644
      not_if do
        ::File.exists?(s3_backup)
      end
    end
  end

  execute "#{bucket}-untar" do
    cwd git_dir
    command "tar -xzf #{s3_backup}"
  end

  execute "#{bucket}-cleanup" do
    cwd git_dir
    command "rm -f #{s3_backup}"
  end

end