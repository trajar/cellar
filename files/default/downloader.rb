
module Cellar
  class Downloader < Base

    def initialize(args)
      @remove_local = true
      @pattern = /.\..tar\.gz$/i
      super(args)
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
      obj = bucket.object(backup_name)
      raise "Unable to locate backup [#{backup_name}] - not found." unless obj.exists?
      tmp_file = Tempfile.new([File.basename(backup_name), '.data'])
      begin
        client.get_object({bucket: bucket_name, key: backup_name}, target: tmp_file)
        Cellar.logger.debug("Backup [#{backup_name}] downloaded to #{tmp_file.size} bytes on disk.")
        yield tmp_file
      ensure
        tmp_file.close
        tmp_file.unlink
      end
    end

  end
end