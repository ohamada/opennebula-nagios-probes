# encoding: UTF-8
%w(hugs digest/sha1 occi/resource occi/network occi/storage occi/compute).each { |r| require r }
module Occi
# OCCI Client class.
# ==== Attributes (required)
# * +user+: A String containing the username for use in HTTP Basic auth.
# * +password+: A String containing the password for use in HTTP Basic auth.
# * +host+: A String with the host to connect.
#
# ==== Options
# * options - Hash with provided command line arguments.

  class Client
    def initialize(options)
      @connection = Hugs::Client.new(
        user: options[:user],
        password: Digest::SHA1.hexdigest(options[:password]),
        host: options[:host],
        scheme: options[:scheme] || 'http',
        port: options[:port] || 4567,
        type: options[:type] || :xml,
        raise_errors: true
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
