
module Cellar
  class Options

    def initialize(script_name)
      @params = {}
      @parser = OptionParser.new
      @parser.banner = "Usage: #{script_name} [options]"
      @parser.on( '-h', '--help') do
        puts @parser
        exit
      end
      @parser.on('-v', '--[no-]verbose') do |v|
        @params[:verbose] = v
      end
      @parser.on('-k', '--key STR') do |v|
        @params[:access_key_id] = v
      end
      @parser.on('-s', '--secret STR') do |v|
        @params[:secret_access_key] = v
      end
      @parser.on('-b', '--bucket STR') do |v|
        @params[:bucket_name] = v
      end
      @parser.on('-r', '--[no-]remove') do |v|
        @params[:remove_local] = v
      end
      @parser.on('-c', '--cleanup STR') do |v|
        @params[:pattern] = Regexp::new(v)
      end
      @parser.on('-k', '--keep NUM') do |v|
        @params[:keep] = v.to_i
      end
    end

    def add(param, short_opt, long_opt)
      @parser.on(short_opt, long_opt) do |v|
        @params[param] = v
      end
      self
    end

    def parse()
      @parser.parse!
      if @params[:verbose]
        Cellar.logger.level = Logger::DEBUG
      else
        Cellar.logger.level = Logger::WARN
      end
      self
    end

    def [](param)
      @params[param]
    end

    def each(&block)
      @params.each &block
    end

  end
end