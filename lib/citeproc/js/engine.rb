require 'multi_json'
require 'execjs'

require 'forwardable'

module CiteProc
  module JS
    
    class Engine < CiteProc::Engine

      @name = 'citeproc-js'.freeze
      @type = 'CSL'.freeze
      @version = '1.0'
      @priority = 0
      
      @path = File.expand_path('../support', __FILE__)

      class << self
        
        attr_reader :path
        
        def parser
          ExecJS.runtime.name =~ /rhino|spidermonkey/i ? 'xmle4x.js' : 'xmldom.js'
        end
        
        # Returns the citeproc-js JavaScript code.
        def source
          @source || reload
        end
        
        # Forces a reload citeproc-js JavaScript code. Returns the source
        # code.
        def reload
          @source = [
            parser, 'citeproc.js', 'system.js'
          ].map { |s| File.open(File.join(path,s), 'r:UTF-8').read }.join.freeze        
        end

        # Returns the citeproc-js version number.
        def processor_version
          @processor_version ||= source.scan(/^\s*this.processor_version = "([\d\.]+)";\s*$/).flatten[0].to_s.freeze
        end
      end
      
      def start
        return if started?
        
        @context = ExecJS.compile(Engine.source)
        update_system
        @context.eval("citeproc = new CSL.Engine(system, #{ style.inspect }, #{ options[:locale].inspect })")
        
        set_output_format(options[:format])
        
        super
      rescue => e
        raise EngineError.new('failed to start engine', e)
      end
      
      def stop
        @context = nil
        super
      end
      
            
      def process
        @context.exec(<<-END)
          //var cad1 = citeproc.appendCitationCluster(citationCAD1);
          //var cad2 = citeproc.appendCitationCluster(citationCAD2);
          //var cad3 = citeproc.appendCitationCluster(citationCAD3);
          
          //citeproc.updateItems(['ITEM-1']);
          return citeproc.processor_version;
        END
      end

      def update_system(*arguments)
        arguments = [:abbreviations, :items, :locales] if arguments.empty?
        @context.eval('system.update(%s)' % MultiJson.encode(Hash[*arguments.flatten.map { |a| [a, send(a)] }.flatten]))
      end

      %w{ processor_version csl_version registry }.each do |attribute|
        define_method(attribute) do
          @context.eval(['citeproc',attribute].join('.'))
        end
      end
      
      # Sets the output format.
      def format=(format)
        @context.eval("citeproc.setOutputFormat(#{ format.to_s.inspect })"); format
      end
      
      alias set_output_format format=
      
      def default_namespace=(namespace)
        @context.eval("citeproc.setAbbreviations(#{ namespace.to_s.inspect })")
        @default_namespace = namespace.to_sym
      end

      alias set_abbreviations default_namespace=
      
      def opt
        @context.eval('citeproc.opt')
      end
      
      alias flags opt
      
      # Loads items into citeproc-js. Available options:
      # :sort: sort items in bibliography depending on style; if set to false
      #        sorting will be suppressed; true by default.
      def update_items(items, options = {})
        @context.eval('citeproc.updateItems(%s,%s)' % [MultiJson.encode(items), !options[:sort]])
      end
      
      def update_uncited_items(items, options = {})
        @context.eval('citeproc.updateUncitedItems(%s,%s)' % [MultiJson.encode(items), !options[:sort]])
      end

      def make_bibliography
        @context.eval('citeproc.makeBibliography()')[1]
      end
      
      alias bibliography make_bibliography
      
    end
    
  end
end
