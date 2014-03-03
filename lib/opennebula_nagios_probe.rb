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

# OpenNebulaProbe - this file serves only as proxy for development and including purposes.

# translate special symbols into readable ones
require 'English'

# include the probe files and a custom version of OCA
$LOAD_PATH << File.expand_path('..', __FILE__) + '/probe'

# include the probe classes and a custom argument parser
require 'opennebula_probe'
require 'optparse_nagios_probe'
require 'opennebula_oned_probe'
require 'opennebula_occi_probe'
require 'opennebula_econe_probe'