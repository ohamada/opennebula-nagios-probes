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
require 'AWS'

class OpenNebulaEconeProbe < OpennebulaProbe

  attr_writer :logger

  def initialize(opts)
    super(opts)
    @connection = AWS::EC2::Base.new(
        :access_key_id     => @opts.username,
        :secret_access_key => @opts.password,
        :server            => @opts.hostname,
        :port              => @opts.port,
        :path              => @opts.path,
        :use_ssl           => @opts.protocol == :https
    )
  end

  def check_crit

    @logger.info "Checking for basic connectivity at " + @endpoint

    begin
      @connection.describe_images
      @connection.describe_instances
    rescue StandardError => e
      @logger.error "Failed to check connectivity: " + e.message
      return true
    end

    false
  end

  def check_resources(resources)
    if resources.map { |x| x[:resource] }.inject(true){ |product,resource| product && resource.nil? }
      @logger.info "There are no resources to check, for details on how to specify resources see --help"
      return false
    end

    resources.each do |resource_hash|
      resource = resource_hash[:resource]

      next if resource.nil?

      @logger.info "Looking for " + resource_hash[:resource_string] + "s: " + resource.inspect
      if resource_hash[:resource_type] == :image
        result = @connection.describe_images
        set = "imagesSet"
        id = "imageId"
      elsif resource_hash[:resource_type] == :compute
        result = @connection.describe_instances
        result = result["reservationSet"]["item"][0] unless result["reservationSet"].nil? || result["reservationSet"]["item"].nil?
        set = "instancesSet"
        id = "instanceId"
      else
        raise StandardError.new("Wrong resource definition")
      end

      @logger.debug result

      raise StandardError.new("No " + resource_hash[:resource_string].capitalize + " found") unless result && result[set]

      resource.each do |resource_to_look_for|
        found = false

        result[set]["item"].each { |resource_found| found = true if resource_to_look_for == resource_found[id] }

        raise StandardError.new(resource_hash[:resource_string].capitalize + " " + resource_to_look_for + "not found") unless found
      end
    end
  end

  def check_warn

    @logger.info "Checking for resource availability at " + @endpoint

    begin
      # iterate over given resources
      @logger.info "Not looking for networks, since it is not supported by OpenNebula's ECONE server'"  unless @opts.network.nil?

      resources = Array.new
      resources << {:resource_type => :image, :resource => @opts.storage, :resource_string => "image"}
      resources << {:resource_type => :compute, :resource => @opts.compute, :resource_string => "compute instance"}

      check_resources(resources)

    rescue StandardError => e
      @logger.error "Failed to check resource availability: " + e.message
      return true
    end

    false
  end
end
