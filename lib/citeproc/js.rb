
require 'citeproc/js/compatibility'

ruby_18 do
  ENV['EXECJS_RUNTIME'] = 'Johnson'
end

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
require 'citeproc/js/assets'
require 'citeproc/js/engine'
