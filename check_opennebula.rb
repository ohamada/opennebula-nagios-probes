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

# translate special symbols into readable ones
require 'English'

# include the probe files and a custom version of OCA
$LOAD_PATH << File.expand_path('..', __FILE__) + '/lib/probe'

# bundler integration and dependencies
require 'rubygems'
require 'bundler/setup'
require 'log4r'
#include Log4r


# include the probe classes and a custom argument parser
require 'opennebula_probe'
require 'optparse_nagios_probe'
require 'opennebula_oned_probe'
require 'opennebula_occi_probe'
require 'opennebula_econe_probe'

begin
  # parse the arguments (type checks, required args etc.)
  options = OptparseNagiosProbe.parse(ARGV)

  # instantiate a probe
  case options.service
  when :oned
    probe = OpenNebulaOnedProbe.new(options)
    logger = Log4r::Logger.new 'OpenNebulaOnedProbe'
  when :occi, :rocci
    probe = OpenNebulaOcciProbe.new(options)
    logger = Log4r::Logger.new 'OpenNebulaOcciProbe'
  when :econe
    probe = OpenNebulaEconeProbe.new(options)
    logger = Log4r::Logger.new 'OpenNebulaEconeProbe'
  end

  # set the logger
  logger.outputters = Log4r::Outputter.stderr
  probe.logger = logger

  case options.debug_level
    when 0
      logger.level = Log4r::ERROR
    when 1
      logger.level = Log4r::INFO
    when 2
      logger.level = Log4r::DEBUG
  end

  # run the probe
  probe.run

  # report the result in a nagios-compatible format
  logger.info probe.message
  logger.info "Probe returned: #{probe.retval.to_s}"
  exit probe.retval

# catch all StandardErrors raised by parser or probes and treat them as a UKNOWN probe state too
rescue StandardError => e
  puts "Fatal exception occured: #{e.message}"
  #puts e.backtrace
  puts UNKNOWN
  exit UNKNOWN
end