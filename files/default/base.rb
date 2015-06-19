
module Cellar
  class Base

    def initialize(args)
      args.each do |k,v|
        instance_variable_set("@#{k}", v) unless v.nil?
      end
    end

    def bucket_name()
      @bucket_name
    end

    def bucket()
      @s3_bucket ||= resource.bucket(@bucket_name)
    end

    def client()
      @s3_client ||= Aws::S3::Client.new(region: region, credentials: Aws::Credentials.new(@access_key_id, @secret_access_key))
    end
    
    def resource()
      @s3_resource ||= Aws::S3::Resource.new(client: client)
    end
    
    def region()
      @s3_region ||= 'us-east-1'
    end

  end
end