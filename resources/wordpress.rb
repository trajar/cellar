
actions :backup, :restore

attribute :bucket,              :kind_of => String, :default => nil
attribute :access_key_id,       :kind_of => String
attribute :secret_access_key,   :kind_of => String

attribute :backup,              :kind_of => String, :default => 'latest'
attribute :minute,              :kind_of => String, :default => node['cellar']['cron']['minute']
attribute :hour,                :kind_of => String, :default => node['cellar']['cron']['hour']
attribute :mailto,              :kind_of => String, :default => node['cellar']['cron']['mailto']
attribute :mysql_pattern,       :kind_of => Regexp, :default => /^wordpress-mysql-.+\.gz$/i
attribute :site_pattern,        :kind_of => Regexp, :default => /^wordpress-site-.+\.gz$/i
attribute :mysql_file_name,     :kind_of => String, :default => 'wordpress-mysql-%Y%m%d%H%M%S.gz'
attribute :site_file_name,      :kind_of => String, :default => 'wordpress-site-%Y%m%d%H%M%S.tar.gz'
attribute :keep,                :kind_of => Integer

attribute :database,            :kind_of => String, :default => nil
attribute :db_user,             :kind_of => String, :default => 'root'
attribute :db_password,         :kind_of => String, :default => node['mysql']['server_root_password']
attribute :site_dir,            :kind_of => String, :default => nil
