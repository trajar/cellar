
actions :backup, :restore

attribute :bucket,              :kind_of => String, :default => 'cellar'
attribute :access_key_id,       :kind_of => String
attribute :secret_access_key,   :kind_of => String

attribute :git_dir,             :kind_of => String

attribute :backup,              :kind_of => String, :default => 'latest'
attribute :mailto,              :kind_of => String, :default => nil
attribute :pattern,             :kind_of => Regexp, :default => /^git-.+\.tar\.gz$/i
attribute :keep,                :kind_of => Integer

attribute :file_name,           :kind_of => String, :default => 'git-%Y%m%d%H%M%S.tar.gz'
