
module Cellar
  class Uploader

    def initialize(args)
      @remove_local = true
      @pattern = /.\..tar\.gz$/i
      args.each do |k,v|
        instance_variable_set("@#{k}", v) unless v.nil?
      end
    end

    def upload_file(file)
      basename = File.basename file
      obj = bucket.objects[basename]
      if obj.exists?
        Cellar.logger.debug "Backup file [#{basename}] already exists."
      else
        Cellar.logger.info "Uploading backup file [#{basename}] to aws-s3 ..."
        obj = bucket.objects[basename]
        obj.write(:file => file)
      end
      File.delete file if @remove_local
    end

    def upload_files(files)
      files.each do |file|
        upload_file(file)
      end
    end

    private

    def bucket()
      @s3_bucket ||= api.buckets[@bucket]
    end

    def api()
      @s3_api ||= AWS::S3.new(:access_key_id => @access_key_id, :secret_access_key => @secret_access_key)
    end

  end
end