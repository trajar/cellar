
['libxslt-dev', 'libxml2-dev'].each do |pkg|
  ctx = package pkg do
    action :nothing
  end
  ctx.run_action(:install)
end

chef_gem 'aws-sdk'
