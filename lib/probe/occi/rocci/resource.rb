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
require 'occi-api'

module Rocci
  class Resource
    include Occi::Api::Dsl

    def initialize(opts)
      connect(:http, opts)
    end

    # Callback invoked whenever a subclass is created. This method dynamically defines virtual @endpoint
    # attribute located in child instance, which contains backslash + name of inheriting class. It is used
    # for request building.
    def self.inherited(childclass)
      super(childclass)

      path = childclass.to_s.split('::').last.downcase

      childclass.send(:define_method, :resource_uri) {"#{path}"}
    end

    def entity(id)
      "/#{resource_uri}/#{id}"
    end

    # Returns the contents of the pool.
    # 200 OK: An XML representation of the pool in the http body.
    # This means query the point "network", "storage" etc.
    # Please read Occi::Api documentation here https://github.com/arax/rOCCI-api.
    def all
      describe(resource_uri)
    end

    # Returns the representation of specific resource identified by +id+.
    # 200 OK: An XML representation of the pool in the http body.
    def find(id)
      describe(entity(id))
    end
  end
end