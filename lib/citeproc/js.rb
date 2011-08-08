
ENV['EXECJS_RUNTIME'] = 'RubyRhino'

require 'ruby-debug'
Debugger.start

require 'citeproc'

require 'citeproc/js/version'
require 'citeproc/js/assets'
require 'citeproc/js/engine'
