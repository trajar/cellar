
actions :backup, :restore

attribute :bucket,              :kind_of => String, :default => 'cellar'
attribute :access_key_id,       :kind_of => String
attribute :secret_access_key,   :kind_of => String

attribute :dir,                 :kind_of => String
attribute :exclude,             :kind_of => Array, :default => []

attribute :backup,              :kind_of => String, :default => 'latest'
attribute :minute,              :kind_of => String, :default => node['cellar']['cron']['minute']
attribute :hour,                :kind_of => String, :default => node['cellar']['cron']['hour']
attribute :mailto,              :kind_of => String, :default => node['cellar']['cron']['mailto']
attribute :pattern,             :kind_of => Regexp, :default => /^dir-.+\.tar\.gz$/i
attribute :keep,                :kind_of => Integer
attribute :file_name,           :kind_of => String, :default => 'dir-%Y%m%d%H%M%S.tar.gz'
