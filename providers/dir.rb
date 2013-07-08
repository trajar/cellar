
action :backup do

  bucket = @new_resource.bucket
  access_key_id = @new_resource.access_key_id
  secret_access_key = @new_resource.secret_access_key
  file_name = @new_resource.file_name
  dir = @new_resource.dir
  pattern = @new_resource.pattern
  keep = @new_resource.keep
  excludes = @new_resource.exclude.join ','
  mailto = @new_resource.mailto
  hour = @new_resource.hour
  minute = @new_resource.minute

  script = "#{node['cellar']['dir']}/backup_dir.rb --dir \"#{dir}\" --exclude \"#{excludes}\" --bucket \"#{bucket}\" --key \"#{access_key_id}\" --secret \"#{secret_access_key}\""
  if file_name
#   script = "#{script} --name \"#{file_name.gsub('%', '\%')}\""
    script = "#{script} --name \"#{file_name}\""
  end
  if pattern
    script = "#{script} --cleanup \"#{pattern.to_s}\""
  end
  if keep
    script = "#{script} --keep #{keep}"
  end

  cron "dir-#{dir}-backup" do
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
  dir = @new_resource.dir
  pattern = @new_resource.pattern
  backup = @new_resource.backup

  if backup.eql?(:latest) || backup.eql?('latest') || backup.nil?
    backup_name = ::Cellar::Downloader.new(:bucket => bucket, :access_key_id => access_key_id, :secret_access_key => secret_access_key, :pattern => pattern).latest_backup
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

    execute "#{bucket}-untar" do
      cwd dir
      command "tar -xzf #{s3_backup}"
    end

  end

end