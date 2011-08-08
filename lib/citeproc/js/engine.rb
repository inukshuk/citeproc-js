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
              delegate "citeproc.#{m}"
            end
          end
        end
        
        def delegate_context(*arguments)
          arguments.flatten.each do |m|
            define_method(underscore(m)) do |*args|
              delegate "citeproc.#{m}(#{args.map { |a| MultiJson.encode(a) }.join(',')})"
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

      def style=(style)
        @style = Style.load(style.to_s)
      end
      
      def locales=(locale)
        @locales = { locale.to_sym => Locale.load(locale.to_s) }
      end
      
      attr_context :processor_version, :csl_version, :opt

      alias flags opt

      delegate_context %w{ setOutputFormat updateItems updateUncitedItems
        makeBibliography appendCitationCluster processCitationCluster
        previewCitationCluster registry.getSortedRegistryItems }
        
      alias format= set_output_format
      alias bibliography make_bibliography

      alias sorted_registry_items get_sorted_registry_items

      %w{ append process preview }.each do |m|
        alias_method m, "#{m}_citation_cluster"
      end
      
      def registry
        @registry ||= Hash.new { |h,k| delegate "citeproc.registry.#{k}" }
      end
      
      def citation_registry
        @citation_registry ||= Hash.new { |h,k| registry["citationreg.#{k}"] }
      end
      
      def language; options[:locale]; end
      
      def start
        return if started?
        super

        self.style = processor.options[:style] if @style.nil?
        self.locales = processor.options[:locale] if @locales.nil?

        @context = ExecJS.compile(Engine.source)
        update_system
        
        delegate "citeproc = new CSL.Engine(system, #{style.inspect}, #{language.inspect})", :exec
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
      
      def set_abbreviations(namespace)
        delegate "citeproc.setAbbreviations(#{ namespace.to_s.inspect })"
        @default_namespace = namespace.to_sym
      end

      alias default_namespace= set_abbreviations
      
      private

      def update_system(*arguments)
        arguments = [:abbreviations, :items, :locales] if arguments.empty?
        delegate "system.update(#{ MultiJson.encode(Hash[*arguments.flatten.map { |a| [a, send(a)] }.flatten]) })"
      end
      
      def delegate(script, method = :eval)
        if running?
          @context.send(method, script)
        else
          warn "not executing script: engine has not been started"
        end
      rescue => e
        raise EngineError.new('failed to execute javascript:', e)
      end
      
    end
    
  end
end
