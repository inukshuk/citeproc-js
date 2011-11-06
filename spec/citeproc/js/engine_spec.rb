require 'spec_helper'

module CiteProc
  module JS
    describe 'Engine' do

      let(:items) { load_items('items') }
      
      let(:processor) do
        p = Processor.new(:style => 'apa')
        p.update(items)
        p
      end

      before(:all) do
        Style.root = File.expand_path('../../../fixtures/styles', __FILE__)
        Locale.root = File.expand_path('../../../fixtures/locales', __FILE__)
      end

      let(:engine) do
        processor.engine = Engine.new(processor)
      end

      it { should_not be nil }


      describe '#version' do
        it 'returns a 1.x version string' do
          engine.version.should =~ /^1\.[\d\.]+/
        end
      end

      describe '#name' do
        it 'returns "citeproc-js"' do
          engine.name.should == 'citeproc-js'
        end
      end

      describe '#type' do
        it 'returns "CSL"' do
          engine.type.should == 'CSL'
        end
      end


      describe '#processor_version' do  
        it 'returns the citeproc-js version' do
          engine.processor_version.should =~ /^[\d\.]+$/
        end
      end

      describe '#flags' do
        it 'returns a hash of flags' do
          engine.flags.should have_key('sort_citations')
        end
      end

      describe '#namespace=' do
        it 'sets the abbreviation namespace' do
          lambda { engine.namespace = :default }.should_not raise_error
        end
      end

      describe '#registry' do
        it 'is a hash' do
          engine.registry.should be_a(Hash)
        end
      end

      describe '#update_items' do
        it 'given a list of ids, loads the corresponding items into the engine' do
          expect { engine.update_items(['ITEM-1']) }.to
          change { engine.registry[:inserts].length }.by(1)
        end
      end

      describe '#bibliography' do
        it 'returns an empty bibliography by default' do
          engine.bibliography[1].should be_empty
        end

        describe 'when items were processed' do
          before(:each) { engine.update_items(['ITEM-1']) }

          it 'returns the bibliography when at least one item was processed' do
            engine.bibliography[1].should_not be_empty
          end
        end
      end

      describe '#sorted_registry_items' do
        it 'returns an empty bibliography by default' do
          engine.sorted_registry_items.should be_empty
        end

        describe 'when items were processed' do
          before(:each) { engine.update_items(['ITEM-1']) }

          it 'returns the bibliography when at least one item was processed' do
            engine.sorted_registry_items.should_not be_empty
          end
        end        
      end

    end

  end  
end