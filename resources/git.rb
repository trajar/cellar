
actions :backup, :restore

attribute :bucket,              :kind_of => String, :default => 'cellar'
attribute :access_key_id,       :kind_of => String
attribute :secret_access_key,   :kind_of => String
attribute :git_dir,             :kind_of => String

attribute :backup,              :kind_of => String, :default => :latest
attribute :pattern,             :regex => /^([a-z]|[A-Z]|[0-9]|_|-)+$/, :default => /.\..tar\.gz$/i

attribute :backup_format,       :kind_of => String, :default => 'git-%Y%m%d%H%M%S.tar.gz'
attribute :backup_dir,          :kind_of => String
