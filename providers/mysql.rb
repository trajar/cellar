
action :backup do

  require "#{node['cellar']['dir']}/cellar.rb"

  bucket = @new_resource.bucket
  access_key_id = @new_resource.access_key_id
  secret_access_key = @new_resource.secret_access_key
  file_name = @new_resource.file_name
  database = @new_resource.database
  db_user = @new_resource.db_user || 'root'
  db_password = @new_resource.db_password || node['mysql']['server_root_password']
  pattern = @new_resource.pattern
  keep = @new_resource.keep
  mailto = @new_resource.mailto
  hour = @new_resource.hour
  minute = @new_resource.minute

  script = "#{node['cellar']['dir']}/backup_mysql.rb --database \"#{database}\" --user \"#{db_user}\" --password \"#{db_password}\" --bucket \"#{bucket}\" --key \"#{access_key_id}\" --secret \"#{secret_access_key}\""
  if file_name
    script = "#{script} --name \"#{file_name.gsub('%', '\%')}\""
  end
  if pattern
    script = "#{script} --cleanup \"#{pattern.to_s}\""
  end
  if keep
    script = "#{script} --keep #{keep}"
  end

  cron "mysql-#{database}-backup" do
    hour hour if hour
    minute minute if minute
    mailto mailto if mailto
    path "#{node['cellar']['path']}"
    command "#{node['cellar']['ruby']} #{script}"
    action :create
  end

end

action :restore do

  require "#{node['cellar']['dir']}/cellar.rb"

  bucket = @new_resource.bucket
  access_key_id = @new_resource.access_key_id
  secret_access_key = @new_resource.secret_access_key
  pattern = @new_resource.pattern
  database = @new_resource.database
  db_user = @new_resource.db_user || 'root'
  db_password = @new_resource.db_password || node['mysql']['server_root_password']
  backup = @new_resource.backup

  if backup.eql?(:latest) || backup.eql?('latest') || backup.nil?
    backup_name = ::Cellar::Downloader.new(:bucket_name => bucket, :access_key_id => access_key_id, :secret_access_key => secret_access_key, :pattern => pattern).latest_backup
  else
    backup_name = backup
  end

  unless backup_name.nil? || backup_name.empty?

    s3_backup = ::File.join Chef::Config[:file_cache_path], "#{bucket}.#{backup_name}"

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

    execute "#{@new_resource.name}-restore-from-mysqldump" do
      command "gzip -cd #{s3_backup} | /usr/bin/mysql --user=\"#{db_user}\" --password=\"#{db_password}\" \"#{database}\" "
    end

  end

end