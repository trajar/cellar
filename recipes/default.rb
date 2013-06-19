
include_recipe 'build-essential'
include_recipe 'xml::ruby'

chef_gem 'aws-sdk'

directory "#{node['cellar']['dir']}" do
  owner 'root'
  group 'root'
  mode '0755'
  action :create
  recursive true
end

cookbook_file "#{node['cellar']['dir']}/backup.rb" do
  source 'backup.rb'
  mode 0755
  owner "root"
  group "root"
end

cookbook_file "#{node['cellar']['dir']}/tarball.rb" do
  source 'tarball.rb'
  mode 0755
  owner "root"
  group "root"
end
