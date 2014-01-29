Nagios probes for OpenNebula v3.4 - v4.4
========================================

[![Build Status](https://travis-ci.org/arax/opennebula-nagios-probes.png)](https://travis-ci.org/arax/opennebula-nagios-probes)

Nagios probes for OpenNebula-related services e.g. oned RPC2, econe-server, occi-server and rOCCI server (EGI implementation)

These probes are written in Ruby, Gemfile for bundler is included.

## Requirements
1.9.1 =< Ruby version =< 2.0.0

## Usage

~~~
./check_opennebula.rb --username <USERNAME> --password <PASSWORD> --hostname <HOSTNAME> --port <PORT_NUMBER> --path /RPC2  --service oned
./check_opennebula.rb --username <USERNAME> --password <PASSWORD> --hostname <HOSTNAME> --port <PORT_NUMBER>  --service occi
./check_opennebula.rb --username <USERNAME> --password <PASSWORD> --hostname <HOSTNAME> --port <PORT_NUMBER>  --service rocci
./check_opennebula.rb --username <USERNAME> --password <PASSWORD> --hostname <HOSTNAME> --port <PORT_NUMBER>  --service econe
~~~

and with optional

* `--timeout` (this option is, for now, ignored by OCCI and ECONE probes)
* `--protocol [https | http]`
* `--debug [number, 0-2]`
* `--check-network <ID>,<ID>,<ID>,...` (this option is ignored by the ECONE probe)
* `--check-storage <ID>,<ID>,<ID>,...` (not supported within rOCCI implementation)
* `--check-compute <ID>,<ID>,<ID>,...`
