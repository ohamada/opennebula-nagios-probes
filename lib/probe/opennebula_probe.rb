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

###########################################################################
# Nagios code explanation (source: https://www.nagios-plugins.org/doc/guidelines.html, q. 11-26-2013)
#
# OK/UP - The plugin was able to check the service and it appeared to be functioning properly
# WARNING - The plugin was able to check the service, but it appeared to be above some "warning"
# threshold or did not appear to be working properly
# CRITICAL/DOWN - The plugin detected that either the service was not running or it was above
# some "critical" threshold
# UNKNOWN - Invalid command line arguments were supplied to the plugin or low-level failures internal to the plugin
# (such as unable to fork, or open a tcp socket) that prevent it from performing the specified operation.
# Higher-level errors (such as name resolution errors, socket timeouts, etc) are outside of the control of plugins
# and should generally NOT be reported as UNKNOWN states.
###########################################################################

OK       = 0
WARNING  = 1
CRITICAL = 2
UNKNOWN  = 3

# OpennebulaProbe covers generic implementation of subprobes.
# ==== Attributes
# * logger - Logger connector.
# * message - Resulting message.
# * retval - Probe status constant.
# * endpoint - Server URI.
#
# ==== Options
# * opts - Hash with parsed command line arguments.
#
# ==== Examples
# Instance is initialized from child class

class OpennebulaProbe
  OK_MSG    = 'Remote resources successfully queried!'
  WARN_MSG  = 'Failed to query specified remote resources!'
  CRIT_MSG  = 'Failed to establish connection with the remote server!'
  UNKWN_MSG = 'An exception or error occured!'

  attr_reader :retval, :message
  attr_writer :logger

  def initialize(opts = {})
    @opts     = opts
    @retval   = UNKNOWN
    @logger   = nil
    @message  = "#{UNKWN_MSG}"
    @endpoint = "#{@opts.protocol.to_s}://#{@opts.hostname}:#{@opts.port.to_s}#{@opts.path}"
  end

  def check_crit
    # overridden in child class
    true
  end

  def check_warn
    # overridden in child class
    true
  end

  def crit?
    return false unless check_crit
    @retval  = CRITICAL
    @message = "CRITICAL: #{CRIT_MSG}"
    true
  end

  def warn?
    return false unless check_warn
    @retval  = WARNING
    @message = "WARNING: #{WARN_MSG}"
    true
  end

  def run
    unless crit?
      unless warn?
        @retval  = OK
        @message = "#{OK_MSG}"
      end
    end
  end
end
