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

$LOAD_PATH << File.expand_path('..', __FILE__)
%w(nocci/resource nocci/network nocci/storage nocci/compute).each { |r| require r }
%w(rocci/resource rocci/network rocci/storage rocci/compute).each { |r| require r }

# OCCI Client class.
# ==== Options
# * options - Hash with provided command line arguments.

module Test
class OcciClient
  def initialize(options)
    @connection = options

    # Select OCCI version
    if options.occi.to_s == 'rocci'
      @occi_ver = "Rocci"
    else
      @occi_ver = "Occi"
    end
  end

  # Dynamically selects the proper class
  def network
    @network  ||= eval("#{@occi_ver}::Network.new @connection")
  end

  def storage
    @storage  ||= eval("#{@occi_ver}::Storage.new @connection")
  end

  def compute
    @compute  ||= eval("#{@occi_ver}::Compute.new @connection")
  end
end
end