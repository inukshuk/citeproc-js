require 'spec_helper'

module CiteProc
  module JS
    
    describe Processor do
      
      describe '#new' do
        it 'returns a new processor' do
          Processor.new.should_not be nil
        end
      end
      
      describe '#process' do
        it { Processor.new.process.should == 'hello' }
      end
    end
    
  end
end