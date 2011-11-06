
require 'citeproc/js/compatibility'

ENV['EXECJS_RUNTIME'] = 'Johnson'

jruby do
  ENV['EXECJS_RUNTIME'] = 'RubyRhino'
end

if ENV['DEBUG']
  require 'ruby-debug'
  Debugger.start
end

require 'multi_json'
require 'execjs'

require 'forwardable'

require 'citeproc'

require 'citeproc/js/version'
require 'citeproc/js/engine'
