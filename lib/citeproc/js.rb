
ENV['EXECJS_RUNTIME'] = 'RubyRhino'

require 'rubygems'

require 'ruby-debug'
Debugger.start

require 'citeproc'

require 'citeproc/js/version'
require 'citeproc/js/engine'
