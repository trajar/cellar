
include_recipe 'build-essential'
include_recipe 'xml::ruby'

chef_gem 'aws-sdk'
gem_package 'aws-sdk'

directory "#{node['cellar']['dir']}" do
  owner 'root'
  group 'root'
  mode '0755'
  action :create
  recursive true
end

%w(backup_dir.rb backup_files.rb backup_mysql.rb).each do |file|
  cookbook_file "#{node['cellar']['dir']}/#{file}" do
    source "#{file}"
    mode '0755'
    owner 'root'
    group 'root'
  end
end

%w(cellar.rb base.rb cleaner.rb options.rb downloader.rb uploader.rb).each do |file|
  cookbook_file "#{node['cellar']['dir']}/#{file}" do
    source "#{file}"
    mode '0644'
    owner 'root'
    group 'root'
  end
end
