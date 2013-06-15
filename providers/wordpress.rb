
action :backup do


end

action :restore do

  backup_name = latest_backup()
  s3_backup = File.join Chef::Config[:file_cache_path], backup_name
  sql_temp = File.join Chef::Config[:file_cache_path], "#{backup_name}.sql"

  s3_file s3_backup do
    source "s3://#{@new_resource.bucket}/#{backup_name}"
    access_key_id @new_resource.access_key_id,
    secret_access_key @new_resource.secret_access_key,
    owner 'root'
    mode 0644
    not_if do
      File.exists?(s3_backup)
    end
  end

  execute "#{backup_name}-untar" do
    cwd node['wordpress']['dir']
    command "tar -xzf #{s3_backup}"
    user 'root'
    umask 0644
  end

  execute "#{backup_name}-chmod" do
    cwd node['wordpress']['dir']
    command "find . -type d -exec chmod 755 {} \\; &&
             find . -type f -exec chmod 644 {} \\; &&
             chown root:root wp-config.php"
  end

  execute "#{backup_name}-databse" do
    db_pwd = node['mysql']['server_root_password']
    db_name = node['wordpress']['db']['database']
    FileList.new(File.join(node['wordpress']['dir'],'*.sql')).each do |sql_backup|
      command "/usr/bin/mysql -u root -p \"#{db_pwd}\" #{db_name} < #{sql_backup}"
    end
  end

  execute "#{backup_name}-site" do
    db_pwd = node['mysql']['server_root_password']
    db_name = node['wordpress']['db']['database']
    command "/usr/bin/mysql -u root -p \"#{db_pwd}\" #{db_name} < #{sql_temp}"
    action :nothing
  end

  template sql_temp do
    source 'wordpress.sql.erb'
    owner 'root'
    group 'root'
    mode '0600'
    variables(
        :table => 'wp_options',
        :siteurl => node['fqdn'],
        :home => node['fqdn']
    )
    notifies :run, "execute[#{backup_name}-site]", :immediately
  end

end

private

def latest_backup()

  s3 = AWS::S3.new(:access_key_id => @new_resource.access_key_id, :secret_access_key => @new_resource.secret_access_key)
  bucket = s3.buckets[@new_resource.bucket]
  if bucket.nil? || !bucket.exists?
    raise "Unable to locate aws bucket [#{options[:bucket]}]."
  end

  items = Array.new
  bucket.objects.each do |obj|
    items.push obj if obj.key.end_with? '.tar.gz'
  end

  if items.empy?
    items.sort! { |a,b| b.last_modified <=> a.last_modified }
  else
    items.first.key
  end

end