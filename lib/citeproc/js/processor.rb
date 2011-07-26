module CiteProc
  module JS
    
    class << self
      def root
        @root ||= File.expand_path('../../../../vendor/citeproc-js', __FILE__)
      end
    end

    class Processor
      
      DEFAULTS = {}

      SOURCES = %w{
        loadabbrevs.js
        xmldom.js
        citeproc.js
        loadlocale.js
        loadsys.js
        loadcsl.js
        loadcites.js
        runcites.js
      }
      
      attr_reader :options
      
      def initialize (options = {})
        @options = DEFAULTS.merge(options)
        @context = ExecJS.compile(SOURCES.map { |s| File.open(File.join(JS.root,s), "r:UTF-8").read }.join)
      end
      
      def process
        @context.exec(<<-END)
        	return 'hello';
        END
      end
      
    end
    
  end
end
