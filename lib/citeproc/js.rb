
ENV['EXECJS_RUNTIME'] = 'RubyRhino'

if ENV['DEBUG']
  require 'ruby-debug'
  Debugger.start
end

require 'citeproc'

require 'citeproc/js/version'
require 'citeproc/js/assets'
require 'citeproc/js/engine'
