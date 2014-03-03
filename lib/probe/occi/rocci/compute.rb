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
  # OCCI Compute class.
  class Compute < Resource
    # Create, check and destroy resource
    def create_check_destroy
      # Build resource
      res = @client.get_resource('compute')
      res.model = model
      res.title = @opts.vmname
      res.hostname = res.title

      # Fill resource mixin
      if @opts.template.include?('http')
        orig_mxn = model.get_by_id(@opts.template)
      else
        orig_mxn = @client.get_mixin(@opts.template, 'os_tpl', true)
      end

      if orig_mxn.nil?
        fail Occi::Api::Client::Errors::AmbiguousNameError, 'Invalid, non-existing or ambiguous mixin (template) name'
      end

      res.mixins << orig_mxn

      # Create and commit resource
      response = create(res)
      new_vm = response.gsub!(@opts.endpoint.chomp('/'), '')

      # Following block checks out for sucessfull VM deployment
      # and clean up then
      begin
        timeout(@opts.timeout) do
          loop do
            d = describe(new_vm).first
            if d.attributes.occi.compute.state == 'active'
              # puts "OK, resource did enter 'active' state in time"
              break
            end
            sleep @opts.timeout / 5
          end
        end
      rescue Timeout::Error
        raise Timeout::Error, "Resource did not enter 'active' state in time!"
      ensure
        delete new_vm
      end
    end
  end
end
