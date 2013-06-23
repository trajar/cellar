
module Cellar
  class Downloader

    def initialize(args)
      @remove_local = true
      @pattern = /.\..tar\.gz$/i
      args.each do |k,v|
        instance_variable_set("@#{k}", v) unless v.nil?
      end
    end

    def latest_backup()
      if bucket.nil? || !bucket.exists?
        raise "Unable to locate aws bucket [#{@bucket}]."
      end
      items = Array.new
      bucket.objects.each do |obj|
        items.push obj if @pattern.match(obj.key)
      end
      if items.empty?
        Cellar.logger.info "No backups found in [#{@bucket}] using #{@pattern}."
        return nil
      end
      items.sort! { |a,b| b.last_modified <=> a.last_modified }
      items.first.key
    end

    def download_backup(file_name = :latest)
      if file_name.eql? :latest
        backup_name = latest_backup()
      else
        backup_name = file_name
      end
      obj = bucket.objects[backup_name]
      raise "Unable to locate backup [#{backup_name}] - not found." unless obj.exists?
      tmp_file = Tempfile.new([File.basename(backup_name), '.data'])
      begin
        obj.read do |chunk|
          tmp_file.write(chunk)
        end
        Cellar.logger.debug("Backup [#{backup_name}] downloaded to #{tmp_file.size} bytes on disk.")
        yield tmp_file
      ensure
        tmp_file.close
        tmp_file.unlink
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