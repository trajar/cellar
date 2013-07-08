
action :backup do

  bucket = @new_resource.bucket
  access_key_id = @new_resource.access_key_id
  secret_access_key = @new_resource.secret_access_key
  git_dir = @new_resource.git_dir
  pattern = @new_resource.pattern
  keep = @new_resource.keep
  file_name = @new_resource.file_name
  mailto = @new_resource.mailto
  hour = @new_resource.hour
  minute = @new_resource.minute

  cellar_dir @new_resource.name do
    bucket bucket
    access_key_id access_key_id
    secret_access_key secret_access_key
    dir git_dir
    pattern pattern if pattern
    keep keep if keep
    file_name file_name if file_name
    hour hour if hour
    minute minute if minute
    mailto mailto if mailto
    action :backup
  end

end

action :restore do

  bucket = @new_resource.bucket
  access_key_id = @new_resource.access_key_id
  secret_access_key = @new_resource.secret_access_key
  git_dir = @new_resource.git_dir
  pattern = @new_resource.pattern
  backup = @new_resource.backup

  cellar_dir @new_resource.name do
    bucket bucket
    access_key_id access_key_id
    secret_access_key secret_access_key
    dir git_dir
    pattern pattern if pattern
    backup backup if backup
    action :restore
  end

  execute "#{bucket}-chmod" do
    cwd "#{git_dir}"
    command "find . -type d -exec chmod 755 {} \\; &&
             find . -type f -exec chmod 644 {} \\; &&
             chown -R git:git * "
    not_if do
      !::File.exists?(git_dir)
    end
  end

end