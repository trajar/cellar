
actions :backup, :restore

attribute :backup,              :kind_of => String, :default => :latest
attribute :pattern,             :regex => /^([a-z]|[A-Z]|[0-9]|_|-)+$/, :default => /.\..tar\.gz$/i
attribute :bucket,              :kind_of => String, :default => 'cellar'
attribute :access_key_id,       :kind_of => String
attribute :secret_access_key,   :kind_of => String
attribute :siteurl,             :kind_of => String
attribute :home,                :kind_of => String
