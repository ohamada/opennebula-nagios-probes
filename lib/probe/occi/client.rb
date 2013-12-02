# encoding: UTF-8
%w(digest/sha1 occi/resource occi/network occi/storage occi/compute).each { |r| require r }
require 'rubygems'
require 'excon'

module Occi
# OCCI Client class.
# ==== Options
# * options - Hash with provided command line arguments.

  class Client
    def initialize(options)
      @connection = Excon.new(
        "#{options.scheme.to_s}://#{options.host}:#{options.port}",
        user: options.user,
        password: Digest::SHA1.hexdigest(options.password),
        expects: [200, 201, 202, 204] # see resource.rb for explanation, expected HTTP codes
      )
    end

    def network
      @network ||= Occi::Network.new @connection
    end

    def storage
      @storage ||= Occi::Storage.new @connection
    end

    def compute
      @compute ||= Occi::Compute.new @connection
    end
  end
end
