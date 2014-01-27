# encoding: UTF-8
%w(occi/resource occi/network occi/storage occi/compute).each { |r| require r }
require 'digest/sha1'
require 'excon'
require 'httparty'

module Occi
# OCCI Client class.
# ==== Options
# * options - Hash with provided command line arguments.

  class Client
    def initialize(options)
      @connection = options
      #@version = options.occi_ver
    end

    def network
      @network ||= Occi::Network.new @connection
      #@network ||= Rocci:Network.new @connection
      #@network ||= "#{occi_ver}".class.new @connection
    end

    def storage
      @storage ||= Occi::Storage.new @connection
    end

    def compute
      @compute ||= Occi::Compute.new @connection
    end
  end
end
