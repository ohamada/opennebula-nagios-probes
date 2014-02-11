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
require 'rubygems'
require 'pp'
require 'openssl'
require 'highline/import'

module Rocci
  include Occi::Cli::Helpers::CreateHelper

  class Compute < Resource
    def create_vm
      type_id = @client.get_resource_type_identifier('compute')
      res = Occi::Core::Resource.new(type_id)
      res.model = model
      #Occi::Cli::Helpers::CreateHelper.helper_create_attach_mixins(@opts, res)
      res.attributes['occi.core.title'] = @opts.vmname
      res.hostname = res.attributes['occi.core.title']

      mxn = Occi::Core::Mixin.new('os_tpl#', @opts.template)
      orig_mxn = mixin(mxn.term, mxn.scheme.chomp('#'), true)
      res.mixins << orig_mxn

      puts "Creating resource #{res.inspect}"
      response = create(res)

      new_vm = response.gsub!(@opts.endpoint.chomp('/'), '')
      d = describe(new_vm).first

      d.attributes.occi.compute.state
    end
  end
end
