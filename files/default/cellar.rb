
require 'rubygems'
require 'rake'
require 'aws-sdk'
require 'optparse'
require_relative 'cleaner.rb'
require_relative 'uploader.rb'
require_relative 'options.rb'

module Cellar

  def self.logger
    unless @logger
      @logger = Logger.new(STDOUT)
      @logger.formatter = proc do |severity, datetime, progname, msg|
        "#{msg}\n"
      end
    end
    @logger
  end

  def self.logger=(logger)
    @logger = logger
  end

end