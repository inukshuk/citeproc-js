# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)

require 'citeproc/js/version'

Gem::Specification.new do |s|
  s.name        = 'citeproc-js'
  s.version     = CiteProc::JS::VERSION.dup
  s.platform    = Gem::Platform::RUBY
  s.authors     = ['Sylvester Keil']
  s.email       = 'http://sylvester.keil.or.at'
  s.homepage    = 'http://inukshuk.github.com/citeproc-js'
  s.summary     = 'A Ruby wrapper around citeproc-js.'
  s.description = 'A Ruby wrapper around the citeproc-js CSL (Citation Style Language) processor.'
  s.license     = 'AGPLv3'
  s.date        = Time.now.strftime('%Y-%m-%d')

  s.add_runtime_dependency('execjs', ['~> 1.2'])

  s.add_development_dependency('rspec', ['>= 2.6.0'])
  s.add_development_dependency('cucumber', ['>= 1.0.2'])

  s.files        = `git ls-files`.split("\n")
  s.test_files   = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables  = []
  s.require_path = 'lib'

  s.rdoc_options      = %w{--line-numbers --inline-source --title "CiteProc-JS\ Rubygem" --main README.md --webcvs=http://github.com/inukshuk/citeproc-js/tree/master/}
  s.extra_rdoc_files  = %w{README.md}
  
end

# vim: syntax=ruby