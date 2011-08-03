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

        private
        
        def attr_context(*arguments)
          arguments.flatten.each do |m|
            define_method(underscore(m)) do
              delegate("citeproc.#{m}")
            end
          end
        end
        
        def delegate_context(*arguments)
          arguments.flatten.each do |m|
            define_method(underscore(m)) do |*args|
              delegate("citeproc.#{m}(#{args.map { |a| MultiJson.encode(a) }.join(',')})")
            end
          end
        end
        
        def underscore(javascript_method)
          word = javascript_method.to_s.split(/\./)[-1]
          word.gsub!(/([A-Z]+)([A-Z][a-z])/, '\1_\2')
          word.gsub!(/([a-z\d])([A-Z])/, '\1_\2')
          word.downcase!
          word
        end
      end
      
      
      #
      # instance methods
      #
      
      attr_context :processor_version, :csl_version, :opt
      alias flags opt

      delegate_context :setOutputFormat
      alias format= set_output_format
  
      def registry
        @registry ||= Hash.new { |h,k| delegate("citeproc.registry.#{k}") }
      end
      
      def start
        return if started?
        super

        @context = ExecJS.compile(Engine.source)
        update_system
        @context.exec("citeproc = new CSL.Engine(system, #{ style.inspect }, #{ options[:locale].inspect })")
        
        set_output_format(options[:format])
        
        self
      rescue => e
        stop
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

      
      def set_abbreviations(namespace)
        @context.eval("citeproc.setAbbreviations(#{ namespace.to_s.inspect })")
        @default_namespace = namespace.to_sym
      end

      alias default_namespace= set_abbreviations

      
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
      
      private
      
      def delegate(script, method = :eval)
        if running?
          @context.send(method, script)
        else
          warn "not executing script: engine has not been started"
        end
      end
    end
    
  end
end
