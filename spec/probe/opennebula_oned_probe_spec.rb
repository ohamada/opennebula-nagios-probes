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

$LOAD_PATH << File.expand_path('..', __FILE__) + '/../../lib/probe'

require 'rubygems'
require 'bundler/setup'
require 'vcr'
require 'webmock'
require 'log4r'
require 'ostruct'

require 'opennebula'

#
#include OpenNebula
#include Log4r

require 'opennebula_oned_probe'

RSpec::Core::DSL.describe OpenNebulaOnedProbe do
  before do
    WebMock.disable_net_connect! allow: 'localhost'

    VCR.configure do |c|
      c.cassette_library_dir = 'spec/probe/fixtures/cassettes/oned'
      c.hook_into :webmock
      # Do not fail if VCR cannot handle request, act as there was not any
      c.allow_http_connections_when_no_cassette = true
    end

    @options = OpenStruct.new

    @options.protocol = :https
    @options.hostname = 'localhost'
    @options.port     = 2345
    @options.path     = '/RPC2'
    @options.username = 'nagios-probes-test'
    @options.password = 'nagios-probes-pass'

    # Adjust for debug purposes
    @options.debug    = false

    @logger = Log4r::Logger.new 'OnedTestLogger'
    @logger.outputters = Log4r::Outputter.stderr
    #@logger.level = Log4r::DEBUG
    @logger.level = Log4r::INFO
  end

  context 'with no resources' do
    before :each do
      @probe = OpenNebulaOnedProbe.new(@options)
      @probe.logger = @logger
    end

    it 'checks basic connectivity with cassette' do
      VCR.use_cassette('oned_critical_no_resources') do
        @probe.check_crit.should be_false
      end
    end

    # without a cassette the probe should report critical state
    it 'checks basic connectivity without cassette' do
      @probe.check_crit.should be_true
    end

    it 'checks for resource availability with cassette' do
      VCR.use_cassette('oned_warning_no_resources') do
        @probe.check_warn.should be_false
      end
    end

    # without a cassette the probe should report warning state
    it 'checks for resource availability without cassette' do
      @probe.check_warn.should be_false
    end
  end

  context 'with resources' do
    before :each do
      # resources should not have an effect on check_crit results
      @options.network = ['3', '4']
      @options.storage = ['6', '7']
      @options.compute = ['11']

      @probe = OpenNebulaOnedProbe.new(@options)
      @probe.logger = @logger
    end

    it 'checks basic connectivity with cassette' do
      VCR.use_cassette('oned_critical_existing_resources') do
        @probe.check_crit.should be_false
      end
    end

    # without a cassette the probe should report critical state
    it 'checks basic connectivity without cassette' do
      @probe.check_crit.should be_true
    end

    it 'checks for resource availability with cassette' do
      VCR.use_cassette('oned_warning_existing_resources') do
        @probe.check_warn.should be_false
      end
    end

    # without a cassette the probe should report warning state
    it 'checks for resource availability without cassette' do
      @probe.check_warn.should be_true
    end
  end

  context 'with nonexisting resources' do
    before :each do
      # resources should not have an effect on check_crit results
      @options.network = ['16', '17']
      @options.storage = ['126', '127']
      @options.compute = ['22']

      @probe = OpenNebulaOnedProbe.new(@options)
      @probe.logger = @logger
    end

    it 'checks basic connectivity with cassette' do
      VCR.use_cassette('oned_critical_nonexisting_resources') do
        @probe.check_crit.should be_false
      end
    end

    # without a cassette the probe should report critical state
    it 'checks basic connectivity without cassette' do
      @probe.check_crit.should be_true
    end

    it 'checks for resource availability with cassette' do
      VCR.use_cassette('oned_warning_nonexisting_resources') do
        @probe.check_warn.should be_true
      end
    end

    # without a cassette the probe should report warning state
    it 'checks for resource availability without cassette' do
      @probe.check_warn.should be_true
    end
  end
end
