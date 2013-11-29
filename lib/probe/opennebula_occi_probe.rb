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

class OpenNebulaOcciProbe < OpennebulaProbe

  def initialize(opts)
    super(opts)

    @connection = Occi::Client.new(
        :host     => @opts.hostname,
        :port     => @opts.port,
        :scheme   => @opts.protocol,
        :user     => @opts.username,
        :password => @opts.password
    )
  end

  def check_crit
    @logger.info "Checking for basic connectivity at #{@endpoint}"

    begin
      # make a few simple queries just to be sure that the service is running
      @connection.network.all
      @connection.compute.all
      @connection.storage.all
    rescue StandardError => e
      @logger.error "Failed to check connectivity: #{e.message}"
      return true
    end

    false
  end

  def check_resources(resources)
    if resources.map { |x| x[:resource] }.inject(true){ |product,resource| product && resource.nil? }
      @logger.info 'There are no resources to check, for details on how to specify resources see --help'
      return false
    end

    resources.each do |resource_hash|
      resource = resource_hash[:resource]

      next unless resource

      begin
        @logger.info "Looking for #{resource_hash[:resource_string]}s: #{resource.inspect}"
        result = resource.collect {|id| resource_hash[:resource_connection].find id }
        @logger.debug result

      end
    end

    false
  end

  def check_warn
    @logger.info "Checking for resource availability at #{@endpoint}"

    resources = []
    resources << {:resource => @opts.storage, :resource_string => 'image', :resource_connection => @connection.storage}
    resources << {:resource => @opts.compute, :resource_string => 'compute instance', :resource_connection => @connection.compute}
    resources << {:resource => @opts.network, :resource_string => 'network', :resource_connection => @connection.network}

    check_resources(resources)

  rescue StandardError => e
    @logger.error "Failed to check resource availability: #{e.message}"
    return true
  end
end
