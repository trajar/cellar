
action :restore do

  require 'rubygems'
  require 'rake'
  require 'aws-sdk'

  bucket = @new_resource.bucket
  access_key_id = @new_resource.access_key_id
  siteurl = @new_resource.siteurl
  home = @new_resource.home
  secret_access_key = @new_resource.secret_access_key
  db_pwd = node['mysql']['server_root_password']
  db_name = node['wordpress']['db']['database']

  if @new_resource.backup.eql? :latest
    backup_name = latest_backup(bucket)
  else
    backup_name = @new_resource.backup
  end

  s3_backup = ::File.join Chef::Config[:file_cache_path], backup_name

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
    cwd node['wordpress']['dir']
    command "tar -xzf #{s3_backup} &&
             find . -maxdepth 1 -type f -name \"*.sql\" -exec {} > /usr/bin/mysql --user=root --password=#{db_pwd} #{db_name} \\; "
    user 'root'
    umask 0644
  end

  execute "#{bucket}-chmod" do
    cwd node['wordpress']['dir']
    command "find . -type d -exec chmod 755 {} \\; &&
             find . -type f -exec chmod 644 {} \\; &&
             chown root:root wp-config.php"
  end

  unless siteurl.nil? || home.nil?
    execute "#{bucket}-site" do
      db_pwd = node['mysql']['server_root_password']
      db_name = node['wordpress']['db']['database']
      table = 'wp_options'
      command "/usr/bin/mysql --user=root --password=#{db_pwd} #{db_name} -e \"
              UPDATE #{table}
              SET option_value = '#{siteurl}'
              WHERE option_name = 'siteurl';

              UPDATE #{table}
              SET option_value = '#{home}'
              WHERE option_name = 'home';
      \""
    end
  end

  execute "#{bucket}-cleanup" do
    cwd node['wordpress']['dir']
    command "rm -f *.sql && rm -f #{s3_backup}"
  end

end

private

def latest_backup(bucket_name)

  s3 = AWS::S3.new(:access_key_id => @new_resource.access_key_id, :secret_access_key => @new_resource.secret_access_key)
  bucket = s3.buckets[bucket_name]
  if bucket.nil? || !bucket.exists?
    raise "Unable to locate aws bucket [#{bucket_name}]."
  end

  items = Array.new
  bucket.objects.each do |obj|
    items.push obj if obj.key.end_with? '.tar.gz'
  end

  if items.empty?
    items.sort! { |a,b| b.last_modified <=> a.last_modified }
  else
    items.first.key
  end

end