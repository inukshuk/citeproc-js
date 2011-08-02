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

      def processor_version
        @context.exec('return citeproc.processor_version;')
      end
      
    end
    
  end
end
