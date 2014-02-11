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

require 'optparse'
require 'ostruct'

# OptparseNagiosProbe - opennebula-nagios probes ARGV parser class.

class OptparseNagiosProbe
  VERSION = 0.99

  def self.parse(args)
    options = OpenStruct.new

    options.debuglevel = 0

    options.hostname = 'localhost'
    options.port     = 2633
    options.path     = '/'
    options.protocol = :http
    options.username = 'oneadmin'
    options.password = 'onepass'

    options.service = :oned
    options.occi    = :occi

    options.timeout = 60

    options.user_cred = nil
    options.voms = false

    opts_ = OptionParser.new do |opts|
      opts.banner = 'Usage: check_opennebula.rb [options]'

      opts.separator ''
      opts.separator 'Connection options:'

      opts.on('--protocol [http|https]', [:http, :https], "Protocol to use, defaults to 'http'") do |protocol|
        options.protocol = protocol
      end

      opts.on('--hostname [HOSTNAME]', String, "Host to be queried, defaults to 'localhost'") do |hostname|
        options.hostname = hostname
      end

      opts.on('--port [PORT_NUMBER]', Integer, "Port to be queried, defaults to '2633'") do |port|
        options.port = port
      end

      opts.on('--path [PATH]', String, 'Path to the service endpoint'\
      + "(the last part of the URI, should always start with a slash), defaults to '/'") do |path|
        options.path = path
      end

      opts.on('--username [USERNAME]', String, 'Username for authentication purposes, '\
      + "defaults to 'oneadmin'") do |username|
        options.username = username
      end

      opts.on('--password [PASSWORD]', String, 'Password for authentication purposes, '\
      + "defaults to 'onepass'") do |password|
        options.password = password
      end

      opts.separator ''
      opts.separator 'Session options:'

      opts.on('--timeout [SECONDS]', Integer, "Timeout time in seconds, defaults to '60'") do |timeout|
        options.timeout = timeout
      end

      opts.separator ''
      opts.separator 'Service options:'

      opts.on('--service [SERVICE_NAME]', [:oned, :occi, :econe, :rocci], 'Name of the cloud service'\
       + " to check [oned, occi, rocci, econe], defaults to 'oned'") do |service|
        options.service = service
      end

      opts.on("--check-network [ID'S]", Array, 'Comma separated list of network IDs to check') do |network|
        options.network = network
      end

      opts.on("--check-storage [ID'S]", Array, 'Comma separated list of storage IDs to check') do |storage|
        options.storage = storage
      end

      opts.on("--check-compute [ID'S]", Array, 'Comma separated list of VM IDs to check') do |compute|
        options.compute = compute
      end

      opts.on("--createvm [TEMPLATE_UUID]", String, 'rOCCI template uuid') do |tmpl|
        options.template_uuid = tmpl
      end

      opts.on("--name [NAME]", String, 'Name for VM instantiated from template') do |vmname|
        options.vmname = vmname
      end

      opts.separator ''
      opts.separator 'X.509 options:'

      opts.on('--user-cred [PATH]', String, "Path to user's X.509 credentials, defaults to ~/.globus/usercred.pem'")\
        do |ucred|
        options.user_cred = ucred
      end

      opts.on('--ca-file [PATH]', String, 'Path to CA certificates bundle in a file') do |cafile|
        options.ca_file = cafile
      end

      opts.on('--ca-path [PATH]', String, 'Path to CA certificates directory, defaults to "/etc/grid-security/certificates"')\
       do |capath|
        options.ca_path = capath
      end

      opts.on('--voms', "--[no-]voms", 'Enable VOMS credentials; modifies behavior of the X.509 authN module')\
       do |voms|
        options.voms = voms
      end

      opts.separator ''
      opts.separator 'Common options:'

      opts.on('--debuglevel [NUMBER]', Integer, "Run with debugging mode on certain level, defaults to '0'") do |debug|
        unless debug
          options.debug_level = 1
        else
          options.debug_level = debug
        end

        # Param. correction - normalize debug level to max 2, minus sign interpreted as switch, no problem there
        options.debug_level %= 3
      end

      opts.on_tail('-h', '--help', 'Show this message') do
        puts opts
        exit!
      end

      opts.on_tail('--version', 'Show version') do
        puts VERSION
        exit!
      end

    end

    opts_.parse!(args)

    # Emphasize required fields
    mandatory = [:protocol, :hostname, :port, :path, :service, :password]
    unless options.user_cred
      mandatory << :username
    end

    options_hash = options.marshal_dump

    # Bug here, i am not sure the mandatory params working
    missing = mandatory.select { |param| options_hash[param].nil? }
    fail StandardError, "Missing required arguments #{missing.join(', ')}" unless missing.empty?

    options
  end
end
