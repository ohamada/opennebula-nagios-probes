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

require 'opennebula_probe'
require 'occi/client'

# OpenNebulaOcciProbe - OCCI client query service implementation.

class OpenNebulaOcciProbe < OpennebulaProbe
  def initialize(opts)
    super(opts)

    if @opts.user_cred
      creds = {
          type:               "x509",
          user_cert:          @opts.user_cred,
          user_cert_password: @opts.password,
          ca_path:            @opts.ca_path,
          ca_file:            @opts.ca_file,
          voms:               @opts.voms
      }
    else
      creds = {
          username: @opts.username,
          password: @opts.password,
          type:     'basic'
      }
    end

    @client = OcciClient.new(
        endpoint: @endpoint,
        auth:     creds,
        occi:     @opts.service,
        template: @opts.template_uuid,
        vmname:   @opts.vmname,
        timeout:  @opts.timeout
    )
  end

  def check_crit
    @logger.info "Checking for basic connectivity at #{@endpoint}"

    begin
      # make a few simple queries just to be sure that the service is running
      @client.network.all
      # Not supported yet
      @client.compute.all unless @opts.service == 'rocci'
      @client.storage.all
    rescue StandardError => e
      @logger.error "Failed to check connectivity: #{e}"
      @logger.debug "#{e.backtrace.join("\n")}"
      return true
    end

    false
  end

  def check_resources(resources)
    # extract key ":resource" from hashes to new array and determine, if any of them are other than nil
    if resources.map { |x| x[:resource] }.reduce(true) { |product, resource| product && resource.nil? }
      @logger.info 'There are no resources to check, for details on how to specify resources see --help'
      return false
    end

    resources.each do |resource_hash|
      resource = resource_hash[:resource]
      next unless resource

      begin
        @logger.info "Looking for #{resource_hash[:resource_string]}s: #{resource.inspect}"
        result = resource.map { |id| resource_hash[:resource_connection].find id }
        @logger.debug result
      end
    end

    false
  end

  def check_warn
    @logger.info "Checking for resource availability at #{@endpoint}"

    resources = []

    # Not supported yet
    unless @opts.service == 'rocci'
      resources << { resource: @opts.storage, resource_string: 'image',
                     resource_connection: @client.storage }
    end
    resources   << { resource: @opts.compute, resource_string: 'compute instance',
                   resource_connection: @client.compute }
    resources   << { resource: @opts.network, resource_string: 'network',
                   resource_connection: @client.network }


    # Additionally create VM from template when using rOCCI if needed
    if (!@opts.template_uuid.nil?)
      @client.compute.create_check_destroy
    else
      check_resources(resources)
    end

    false

  rescue StandardError => e
    @logger.error "Failed to check resource availability: #{e.message}"
    @logger.debug "#{e.backtrace.join("\n")}"
    return true
  end
end