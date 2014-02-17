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
require 'occi-cli'
require 'occi-core'
require 'occi-api'
require 'timeout'

module Rocci
  #include Occi::Cli::Helpers::CreateHelper

  class Compute < Resource

    # Create, check and destroy resource
    def create_check_destroy
      # Build resource
      type_id = @client.get_resource_type_identifier('compute')
      res = Occi::Core::Resource.new(type_id)
      res.model = model
      res.attributes['occi.core.title'] = @opts.vmname
      res.hostname = res.attributes['occi.core.title']

      # Fill resource mixin
      orig_mxn = @client.get_mixin(@opts.template, "os_tpl", describe = true)
      raise StandardError, "Specified template doesn't exist!" unless orig_mxn

      res.mixins << orig_mxn

      # Create and commit resource
      response = create(res)
      new_vm = response.gsub!(@opts.endpoint.chomp('/'), '')

      # Following block checks out for sucessfull VM deployment
      # and clean up then
      begin
        status = Timeout::timeout(@opts.timeout) {
          loop do
            d = describe(new_vm).first
            if d.attributes.occi.compute.state == 'active'
              #puts "OK, resource did enter 'active' state in time"
              break
            end
            sleep @opts.timeout/5
          end
        }
      rescue Timeout::Error => ex
        raise Timeout::Error, "Resource did not enter 'active' state in time!"
      ensure
        delete new_vm
      end
    end
  end
end
