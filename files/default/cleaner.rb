
module Cellar
  class Cleaner

    def initialize(args)
      @keep = 5
      @pattern = /.\..tar\.gz$/i
      args.each do |k,v|
        instance_variable_set("@#{k}", v) unless v.nil?
      end
    end

    def cleanup_bucket()
      # read all backup files, keeping only the most recent
      if @keep > 0
        items = Array.new
        Cellar.logger.debug "Cleaning up old backups using regex #{@pattern.to_s} ..."
        bucket.objects.each do |obj|
          items.push obj if @pattern.match(obj.key)
        end
        items.sort! { |a,b| b.last_modified <=> a.last_modified }
        if items.size > @keep
          old_items = items[@keep, items.size]
          old_items.reverse!.each do |item|
            Cellar.logger.info "Removing old backup file [#{item.key}] from aws-s3 ..."
            item.delete
          end
        end
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