#!/usr/bin/env ruby
# encoding: UTF-8

###########################################################################
## Licensed under the Apache License, Version 2.0 (the "License");
## you may not use this file except in compliance with the License.
## You may obtain a copy of the License at
##
##    http://www.apache.org/licenses/LICENSE-2.0
##
## Unless required by applicable law or agreed to in writing, software
## distributed under the License is distributed on an "AS IS" BASIS,
## WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
## See the License for the specific language governing permissions and
## limitations under the License.
###########################################################################
require 'httparty'

module Occi
# OCCI Resource class.
  class Resource
    include HTTParty

    def initialize(connection)
      self.class.base_uri "#{connection[:endpoint]}"
      # nebula OCCI format
      self.class.basic_auth "#{connection[:auth][:username]}", Digest::SHA1.hexdigest(connection[:auth][:password])

      # Low-level debugging
      # self.class.debug_output
    end

    # Callback invoked whenever a subclass is created. This method dynamically defines virtual @endpoint
    # attribute located in child instance, which contains backslash + name of inheriting class. It is used
    # for request building.
    def self.inherited(childclass)
      super(childclass)

      path = childclass.to_s.split('::').last.downcase

      childclass.send(:define_method, :endpoint) { "/#{path}" }
    end

    def entity(id)
      "#{endpoint}/#{id}"
    end

    # Returns the contents of the pool.
    # 200 OK: An XML representation of the pool in the http body.
    # This means query the point /network, /storage etc.
    def all
      begin
        response = self.class.get(endpoint)
      rescue => e
        raise e.class, 'Could not initiate basic endpoint connectivity query, maybe HTTP/SSL server problem?'
      ensure
        if !response.nil?
          fail HTTPResponseError, "Basic pool availibility request failed! #{response.body}" unless response.code.between?(200, 300)
          response.body
        else
          fail HTTPResponseError, 'Basic pool availibility request failed!'
        end
      end
    end

    # Returns the representation of specific resource identified by +id+.
    # 200 OK: An XML representation of the pool in the http body.
    def find(id)
      begin
        response = self.class.get(entity(id))
      rescue => e
        raise e.class, 'Could not initiate specific resource query, maybe HTTP/SSL server problem?'
      ensure
        if !response.nil?
          fail HTTPResponseError, "Specific resource request failed! #{response.body}" unless response.code.between?(200, 300)
          response.body
        else
          fail HTTPResponseError, 'Specific resource request failed!'
        end
      end
    end
  end

# HTTPResponseError class.
# Slightly modified HTTParty::ResponseError
# for better cooperation with existing code

  class HTTPResponseError < HTTParty::ResponseError
    attr_reader :message

    def initialize(m)
      super(m)
      @message = m
    end
  end
end
