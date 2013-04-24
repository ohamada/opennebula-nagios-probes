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

$: << File.expand_path("..", __FILE__) + "/../../lib/probe"

require 'rubygems'
require 'bundler/setup'
require 'vcr'
require 'webmock'
require 'nagios-probe'
require 'AWS'
require 'log4r'
require 'ostruct'

require 'opennebula_econe_probe'

include Log4r

describe OpenNebulaEconeProbe do
  before do
    WebMock.disable_net_connect! :allow => "localhost"

    VCR.configure do |c|
      c.cassette_library_dir = 'spec/probe/fixtures/cassettes/econe'
      c.hook_into :webmock
    end

    @options = OpenStruct.new

    @options.protocol = :https
    @options.hostname = "localhost"
    @options.port     = 2345
    @options.path     = "/"
    @options.username = "nagios-probes-test"
    @options.password = "1b5834c03b1a9fda89b38c081a6d99af634b046e"

    @logger = Logger.new 'TestLogger'
  end

  context "with no resources" do
    before :each do
      @probe = OpenNebulaEconeProbe.new(@options)
      @probe.logger = @logger
    end

    it 'checks basic connectivity with cassette' do
      VCR.use_cassette('econe_critical_no_resources') do
        @probe.check_crit.should be_false
      end
    end

    # without a cassette the probe should report critical state
    it 'checks basic connectivity without cassette' do
      @probe.check_crit.should be_true
    end

    it 'checks for resource availability with cassette' do
      VCR.use_cassette('econe_warning_no_resources') do
        @probe.check_warn.should be_false
      end
    end

    # without a cassette the probe should report warning state
    it 'checks for resource availability without cassette' do
      @probe.check_warn.should be_false
    end
  end

  context "with resources" do
    before :each do
      #resources should not have an effect on check_crit results
      @options.storage = ["ami-00000006","ami-00000007"]
      @options.compute = ["i-00000011"]

      @probe = OpenNebulaEconeProbe.new(@options)
      @probe.logger = @logger
    end

    it 'checks basic connectivity with cassette' do
      VCR.use_cassette('econe_critical_existing_resources') do
        @probe.check_crit.should be_false
      end
    end

    # without a cassette the probe should report critical state
    it 'checks basic connectivity without cassette' do
      @probe.check_crit.should be_true
    end

    it 'checks for resource availability with cassette' do
      VCR.use_cassette('econe_warning_existing_resources') do
        @probe.check_warn.should be_false
      end
    end

    # without a cassette the probe should report warning state
    it 'checks for resource availability without cassette' do
      @probe.check_warn.should be_true
    end
  end

  context "with nonexisting resources" do
    before :each do
      #resources should not have an effect on check_crit results
      @options.storage = ["ami-00000126","ami-00000127"]
      @options.compute = ["i-00000022"]

      @probe = OpenNebulaEconeProbe.new(@options)
      @probe.logger = @logger
    end

    it 'checks basic connectivity with cassette' do
      VCR.use_cassette('econe_critical_nonexisting_resources') do
        @probe.check_crit.should be_false
      end
    end

    # without a cassette the probe should report critical state
    it 'checks basic connectivity without cassette' do
      @probe.check_crit.should be_true
    end

    it 'checks for resource availability with cassette' do
      VCR.use_cassette('econe_warning_nonexisting_resources') do
        @probe.check_warn.should be_true
      end
    end

    # without a cassette the probe should report warning state
    it 'checks for resource availability without cassette' do
      @probe.check_warn.should be_true
    end
  end
end