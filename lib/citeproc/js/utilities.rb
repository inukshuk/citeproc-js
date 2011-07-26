module CiteProc
  module JS
    
      module_function
      
      def process (*arguments)
        Processor.new.process(*arguments)
      end
      
      
  end
end
