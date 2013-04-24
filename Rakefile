require 'erb'
require 'rspec/core'
require 'rspec/core/rake_task'

desc 'Default target, runs probe:test'
task :default => 'probe:test'

namespace :probe do

  directory 'build/check_opennebula'
  RSpec::Core::RakeTask.new(:rspec)

  desc 'Check for required dependencies'
  task :dependencies do
    puts 'Checking for required dependencies...'

    `bundle check`
  end

  desc 'Run basic tests'
  task :test do
    puts 'Running basic tests...'

    Rake::Task['probe:rspec'].invoke
  end

  desc 'Install the opennebula probe'
  task :install => ['build/check_opennebula', 'probe:dependencies', 'probe:test'] do
    puts 'Installing the opennebula probe...'

    services = [:oned, :occi, :econe]
    protocols = [:http, :https]

    nagios_command_path = ENV['NAGIOS_COMMAND_PATH'] || '/etc/nagios-plugins/config'
    nagios_plugin_path = ENV['NAGIOS_PLUGIN_PATH'] || '/usr/lib/nagios/plugins'
    ruby_command_path = ENV['RUBY_COMMAND_PATH'] || ''

    cfg = ERB.new File.new('conf/opennebula.cfg.erb').read

    File.open('build/opennebula.cfg', 'w') {|file| file.write(cfg.result(binding)) }

    cp_r 'lib', 'build/check_opennebula'
    cp 'check_opennebula.rb', 'build/check_opennebula'

  end

  desc 'Uninstall the opennebula probe'
  task :uninstall do
    puts 'Uninstalling the opennebula probe...'

    nagios_command_path = ENV['NAGIOS_COMMAND_PATH'] || '/etc/nagios-plugins/config'
    nagios_plugin_path = ENV['NAGIOS_PLUGIN_PATH'] || '/usr/lib/nagios/plugins'

    rm_rf "#{nagios_plugin_path}/check_opennebula"
    rm "#{nagios_command_path}/opennebula.cfg"
  end

  desc 'Remove temporary files and directories created during installation process'
  task :clean do
    puts 'Removing temporary files and directories...'

    rm_rf 'build'
  end

end
