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
require 'OpenNebula'

include OpenNebula

class OpenNebulaOnedProbe < OpennebulaProbe

  attr_writer :logger

  FAILED_CONNECTIVITY = 'Failed to check connectivity: '
  FAILED_RESOURCE = 'Failed to check resource availability: '

  def initialize(opts)
    super(opts)
    # OpenNebula credentials
    @credentials = "#{@opts.username}:#{@opts.password}"
    @client = Client.new(@credentials, @endpoint)
  end

  def check_crit
    @logger.info "Checking for basic connectivity at #{@endpoint}"

    pool_class_array = [VirtualNetworkPool, ImagePool, VirtualMachinePool]
    pool_class_array.each do |pool_class|
      pool = pool_class.new(@client, -1)
      check_rc(pool, FAILED_CONNECTIVITY)
    end

    false

  rescue StandardError => e
    @logger.error "Failed to check connectivity: #{e.message}"
    return true
  end

  def check_rc(pool, msg)
    rc = pool.info
    raise "#{msg} #{rc.message}" if OpenNebula.is_error?(rc)
  end

  def check_resources(resources)
    if resources.map { |x| x[:resource] }.inject(true){ |product,resource| product && resource.nil? }
      @logger.info 'There are no resources to check, for details on how to specify resources see --help'
      return false
    end

    resources.each do |resource_hash|
      resource = resource_hash[:resource]

      next unless resource

      @logger.info "Looking for #{resource_hash[:resource_string]}s: #{resource.inspect}"
      pool = resource_hash[:resource_pool].new(@client, -1)
      check_rc(pool, FAILED_RESOURCE)

      resource.each do |resource_to_look_for|
        found = false

        pool.each do |res|
          check_rc(res, FAILED_RESOURCE)
          found = true if res.id.to_s == resource_to_look_for
        end
        raise "#{resource_hash[:resource_string].capitalize} #{resource_to_look_for} not found" unless found
      end
    end

    false
  end

  def check_warn
    @logger.info "Checking for resource availability at #{@endpoint}"

    resources = []
    resources << {resource: @opts.storage, resource_string: 'image', resource_pool: ImagePool}
    resources << {resource: @opts.compute, resource_string: 'compute instance', resource_pool: VirtualMachinePool}
    resources << {resource: @opts.network, resource_string: 'network', resource_pool: VirtualNetworkPool}

    check_resources(resources)

  rescue StandardError => e
    @logger.error "Failed to check resource availability: #{e.message}"
    return true
  end
end
