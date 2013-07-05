
actions :backup, :restore

attribute :bucket,              :kind_of => String, :default => 'cellar'
attribute :access_key_id,       :kind_of => String
attribute :secret_access_key,   :kind_of => String

attribute :database,            :kind_of => String
attribute :db_user,             :kind_of => String
attribute :db_password,         :kind_of => String

attribute :backup,              :kind_of => String, :default => 'latest'
attribute :mailto,              :kind_of => String, :default => nil
attribute :pattern,             :kind_of => Regexp, :default => /^mysql-.+\.gz$/i
attribute :keep,                :kind_of => Integer

attribute :file_name,           :kind_of => String, :default => 'mysql-%Y%m%d%H%M%S.gz'
