
module Cellar
  class Cleaner < Base

    def initialize(args)
      @keep = 5
      @pattern = /.\..tar\.gz$/i
      super(args)
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

  end
end