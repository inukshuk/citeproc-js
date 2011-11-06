
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



      attr_context :processor_version, :csl_version, :opt

      alias flags opt

      delegate_context %w{ setOutputFormat updateItems updateUncitedItems
        makeBibliography appendCitationCluster processCitationCluster
        previewCitationCluster registry.getSortedRegistryItems }

      alias format= set_output_format

      alias sorted_registry_items get_sorted_registry_items

      %w{ append process preview }.each do |m|
        alias_method m, "#{m}_citation_cluster"
      end

      # Don't expose all delegates to public interface
      private :opt, :append_citation_cluster, :process_citation_cluster,
        :set_output_format, :make_bibliography, :preview_citation_cluster,
        :get_sorted_registry_items

      def registry
        @registry ||= Hash.new { |h,k| delegate "citeproc.registry.#{k}" }
      end

      def citation_registry
        @citation_registry ||= Hash.new { |h,k| registry["citationreg.#{k}"] }
      end

      # The processor's items converted to citeproc-js format
      def items
        Hash[*processor.items.map { |id, item|
          [id.to_s, item.respond_to?(:to_citeproc) ? item.to_citeproc : item.to_s]
        }.flatten]
      end
      
      # The locale put into a hash to make citeproc-js happy
      def locales
        { locale.name => locale.to_s }
      end
      
      # Sets the abbreviation's namespace, both in Ruby and JS land
      def namespace=(namespace)
        delegate "citeproc.setAbbreviations(#{ namespace.to_s.inspect })"
        @namespace = namespace.to_sym
      end

      def bibliography(selector = Selector.new)
        Bibliography(make_bibliography(selector.to_citeproc))
      end
            
      def append(citation)
        append_citation_cluster(citation.to_citeproc, false)
      end
      
      private

      def context
        @context || compile_context
      end

      def compile_context
        @context = ExecJS.compile(Engine.source)
        update_system(:abbreviations, :items, :locales)

        delegate "citeproc = new CSL.Engine(system, #{style.to_s.inspect}, #{locale.name.inspect})", :exec
        set_output_format(options[:format])

        @context
      rescue => e
        raise EngineError, "failed to compile engine context: #{e.message}"
      end

      def update_system(*arguments)
        arguments = arguments.flatten.map { |a| [a, send(a)] }
        delegate "system.update(#{ MultiJson.encode(Hash[*arguments.flatten]) })"
      end

      def delegate(script, method = :eval)
        context.send(method, script)
      rescue => e
        raise EngineError, "failed to execute javascript: #{e.message}"
      end

    end

  end
end
