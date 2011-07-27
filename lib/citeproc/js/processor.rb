module CiteProc
  module JS
    
    class Processor
      
      class << self
        def vendor
          @vendor ||= File.expand_path('../../../../vendor', __FILE__).freeze
        end

        def xml_parser
          ExecJS.runtime.name =~ /rhino|spidermonkey/i ? 'xmle4x.js' : 'xmldom.js'
        end
        
        def source
          @source ||= [
            File.join(vendor, 'citeproc-js', xml_parser),
            File.join(vendor, 'citeproc-js', 'citeproc.js'),
            File.join(vendor, 'citeproc-js', 'loadcites.js'),
            File.expand_path('../support/system.js', __FILE__)
          ].map { |s| File.open(s, 'r:UTF-8').read }.join.freeze        
        end
        
        def defaults
          @defaults ||= {
            :language => 'en-US',
            :style => 'chicago-author-date'
          }.freeze
        end        
      end
      
      attr_reader :options, :abbreviations, :data
      
      def initialize (options = {})
        @options = self.class.defaults.merge(options)
        @abbreviations = { :default => {} }
        @data = {}
        @context = ExecJS.compile(self.class.source)
      end
      
      def process
        locale = File.open(File.expand_path('../../../../vendor/locales/locales-en-US.xml', __FILE__), 'r:UTF-8').read
        style = File.open(File.expand_path('../../../../vendor/styles/chicago-author-date.csl', __FILE__), 'r:UTF-8').read
        @context.exec(<<-END)
        	var system = new System(), citeproc;
        	system.abbreviations = #{ @abbreviations.to_json };
        	system.items = data;
        	system.locales = #{ { 'en_US' => locale }.to_json };
        	//citeproc = new CSL.Engine(system, #{ style.to_json });
        	return 'hello';
        END
      end
      
    end
    
  end
end
