require 'spec_helper'

module CiteProc
  module JS
    describe 'Engine' do
      before(:all) do
        Style.root = File.expand_path('../../../fixtures/styles', __FILE__)
        Locale.root = File.expand_path('../../../fixtures/locales', __FILE__)
      end
      
      let(:subject) do
        Engine.new do |e|
          p = double(:processor)
          p.stub(:options).and_return { Processor.defaults }
          p.stub(:items).and_return { load_items('items') }
          e.processor = p
        end
      end
      
      it { should_not be nil }
      
      describe '#style' do
        let(:apa) { load_style('apa') }
        it 'accepts a style name' do
          subject.style = :apa
          subject.style.to_s.should == apa
        end
        it 'accepts a style name with extension' do
          subject.style = 'apa.csl'
          subject.style.to_s.should == apa
        end
        it 'accepts a full style' do
          subject.style = apa
          subject.style.to_s.should == apa
        end
      end
      
      describe '#version' do
        it 'returns a 1.x version string' do
          subject.version.should =~ /^1\.[\d\.]+/
        end
      end

      describe '#name' do
        it 'returns "citeproc-js"' do
          subject.name.should == 'citeproc-js'
        end
      end
      
      describe '#type' do
        it 'returns "CSL"' do
          subject.type.should == 'CSL'
        end
      end
      
      context 'when started' do
        let(:subject) do
          Engine.new do |e|
            p = double(:processor)
            p.stub(:options).and_return { Processor.defaults }
            p.stub(:items).and_return { load_items('items') }
            e.processor = p
            e.style = :apa
            e.locales = :'en-US'
            e.start
          end
        end

        describe '#processor_version' do  
          it 'returns the citeproc-js version' do
            subject.processor_version.should =~ /^[\d\.]+$/
          end
        end
        
        describe '#flags' do
          it 'returns a hash of flags' do
            subject.flags.should have_key('sort_citations')
          end
        end

        describe '#default_namespace=' do
          it 'sets the abbreviation namespace' do
            lambda { subject.default_namespace = :default }.should_not raise_error
          end
        end

        describe '#registry' do
          it 'is a hash' do
            subject.registry.should be_a(Hash)
          end
        end
        
        describe '#update_items' do
          it 'given a list of ids, loads the corresponding items into the engine' do
            expect { subject.update_items(['ITEM-1']) }.to
              change { subject.registry[:inserts].length }.by(1)
          end
        end

        describe '#bibliography' do
          it 'returns an empty bibliography by default' do
            subject.bibliography[1].should be_empty
          end

          describe 'when items were processed' do
            before(:each) { subject.update_items(['ITEM-1']) }
            
            it 'returns the bibliography when at least one item was processed' do
              subject.bibliography[1].should_not be_empty
            end
          end
        end
        
        describe '#sorted_registry_items' do
          it 'returns an empty bibliography by default' do
            subject.sorted_registry_items.should be_empty
          end

          describe 'when items were processed' do
            before(:each) { subject.update_items(['ITEM-1']) }
            
            it 'returns the bibliography when at least one item was processed' do
              subject.sorted_registry_items.should_not be_empty
            end
          end        
        end
        
      end
      
    end  
  end
end