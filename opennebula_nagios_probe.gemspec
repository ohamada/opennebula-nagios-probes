# coding: utf-8

Gem::Specification.new do |gem|
  gem.name          = 'opennebula_nagios_probe'
  gem.version       = '1.0.0'
  gem.authors       = ['Boris Parak', 'Filip Hubik', 'Michal Kimle' ]
  gem.email         = ['parak@cesnet.cz', 'hubik@ics.muni.cz', 'kimle.michal@gmail.com']
  gem.description   = %q{This gem is collection of nagios probes (one, econe, occi, rocci) for OpenNebula cloud platform}
  gem.summary       = %q{OpenNebula nagios probes}
  gem.homepage      = 'https://github.com/arax/opennebula-nagios-probes'
  gem.license       = 'Apache License, Version 2.0'

  gem.files         = `git ls-files`.split("\n")
  gem.test_files    = `git ls-files -- {test,spec}/*`.split("\n")
  gem.require_paths = ['lib']
  gem.executables   = ['check_opennebula']

  gem.add_dependency 'nagios-probe',	'~> 0.1'
  gem.add_dependency 'log4r',		'~> 1.1'
  gem.add_dependency 'amazon-ec2',	'~> 0.9'
  gem.add_dependency 'occi-cli',	'~> 4.2'
  gem.add_dependency 'opennebula-oca',  '~> 4.4'
  gem.add_dependency 'occi-api', 	'~> 4.2'

  gem.add_development_dependency 'rspec',          '~> 2.14'
  gem.add_development_dependency 'webmock',        '~> 1.9'
  gem.add_development_dependency 'vcr',            '~> 2.8'
  gem.add_development_dependency 'rake', 	   '~> 10.1'
  gem.add_development_dependency 'bundler', 	   '~> 1.3'  

  gem.required_ruby_version     = '>= 1.9.3'
end
