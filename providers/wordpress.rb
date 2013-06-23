
action :backup do

  bucket = @new_resource.bucket
  access_key_id = @new_resource.access_key_id
  secret_access_key = @new_resource.secret_access_key
  database = @new_resource.database
  db_user = @new_resource.db_user
  db_password = @new_resource.db_password
  mysql_pattern = @new_resource.mysql_pattern
  mysql_file_name = @new_resource.mysql_file_name
  site_dir = @new_resource.site_dir
  site_pattern = @new_resource.site_pattern
  site_file_name = @new_resource.site_file_name
  keep = @new_resource.keep

  cellar_dir "#{@new_resource}-site" do
    bucket bucket
    access_key_id access_key_id
    secret_access_key secret_access_key
    dir site_dir
    exclude ['wp-config.php', '*/wp-backup/*.*' '*.tar.gz', '.git', '.svn']
    pattern site_pattern if site_pattern
    keep keep if keep
    file_name site_file_name if site_file_name
    action :backup
  end

  cellar_mysql "#{@new_resource}-mysql" do
    bucket bucket
    access_key_id access_key_id
    secret_access_key secret_access_key
    database database
    db_user db_user
    db_password db_password
    pattern mysql_pattern if mysql_pattern
    keep keep if keep
    file_name mysql_file_name if mysql_file_name
    action :backup
  end

end

action :restore do

  bucket = @new_resource.bucket
  access_key_id = @new_resource.access_key_id
  secret_access_key = @new_resource.secret_access_key
  database = @new_resource.database
  db_user = @new_resource.db_user
  db_password = @new_resource.db_password
  mysql_pattern = @new_resource.mysql_pattern
  mysql_file_name = @new_resource.mysql_file_name
  site_dir = @new_resource.site_dir
  site_pattern = @new_resource.site_pattern
  site_file_name = @new_resource.site_file_name
  backup = @new_resource.backup

  cellar_dir "#{@new_resource}-site" do
    bucket bucket
    access_key_id access_key_id
    secret_access_key secret_access_key
    dir site_dir
    pattern site_pattern if site_pattern
    backup backup if backup
    action :restore
  end

  cellar_mysql "#{@new_resource}-mysql" do
    bucket bucket
    access_key_id access_key_id
    secret_access_key secret_access_key
    database database
    db_user db_user
    db_password db_password
    pattern mysql_pattern if mysql_pattern
    backup backup if backup
    action :restore
  end

  execute "#{@new_resource.name}-chmod" do
    cwd "#{site_dir}"
    command "find . -type d -exec chmod 755 {} \\; &&
             find . -type f -exec chmod 644 {} \\; &&
             chown -R www-data:www-data * &&
             chown root:root wp-config.php"
  end

end
