
module Cellar
  class Uploader < Base

    def initialize(args)
      @remove_local = true
      super(args)
    end

    def upload_file(file, name = nil)
      name = File.basename(file) if name.nil?
      obj = bucket.object(name)
      if obj.exists?
        Cellar.logger.debug "Backup file [#{name}] already exists."
      else
        Cellar.logger.info "Uploading backup file [#{name}] to aws-s3 ..."
        obj. upload_file(file)
      end
      File.delete file if @remove_local
    end

    def upload_files(files)
      files.each do |file|
        upload_file(file)
      end
    end

  end
end