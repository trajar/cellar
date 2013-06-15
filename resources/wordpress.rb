
actions :backup, :restore

attribute :backup,              :kind_of => [ Integer, FalseClass ]
attribute :group,               :regex => /^([a-z]|[A-Z]|[0-9]|_|-)+$/, /^\d+$/
attribute :owner,               :regex => [ /^([a-z]|[A-Z]|[0-9]|_|-)+$/, /^\d+$/ ]
attribute :mode,                :regex => /^0?\d{3,4}$/
attribute :path,                :kind_of => String
attribute :pattern,             :regex => /^([a-z]|[A-Z]|[0-9]|_|-)+$/, :default => /.\..tar\.gz$/i
attribute :bucket,              :kind_of => String, :default => 'cellar'
attribute :access_key_id,       :kind_of => String
attribute :secret_access_key,   :kind_of => String
