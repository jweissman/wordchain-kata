require 'pry'
require 'spec_helper'
require 'wordchain'

describe Wordchain do
  it "should have a VERSION constant" do
    expect(subject.const_get('VERSION')).to_not be_empty
  end
end

describe Dictionary do
  subject(:dictionary) { Dictionary.new }

  it { should_not be_empty }
  it 'should have the expected number of entries' do
    expect(dictionary.size).to eq(235_886)
  end

  it { should include('aardvark') }
  it { should include('dirigible') }
  it { should include('ringmaster') }
  it { should include('hammerer') }
end

describe Chain do
  subject(:chain) do
    Chain.new(dictionary: dictionary, root_word: root_word)
  end

  context 'with a simple dictionary' do
    let(:dictionary) do
      Dictionary.new(entries: simple_entries)
    end

    let(:root_word) { 'okay' }

    let(:simple_entries) do
      %w[ star stag ruby rubs coal robs rods rode code cord ]
    end

    it 'should find candidates for next element of chain' do
      expect(chain.send(:candidates_for,'star')).to eql(['stag'])
      expect(chain.send(:candidates_for,'boat')).to eql([])
    end

    context 'from ruby to code' do
      let(:root_word) { 'ruby' }
      let(:final_word) { 'code' }
      it 'should assemble the chain' do
        expect(chain.to(final_word)).to eq(%w[ ruby rubs robs rods rode code ])
      end
    end
  end

  context 'with a real dictionary' do
    let(:dictionary) { Dictionary.new }

    context 'lead into gold' do
      let(:root_word) { 'lead' }
      let(:end_with) { 'gold' }
      it 'should assemble the chain' do
        expect(chain.to(end_with)).to eq(%w[ lead load goad gold ])
      end
    end

    context 'from cat to dog' do
      let(:root_word) { 'cat' }
      let(:end_with) { 'dog' }
      it 'should assemble the chain' do
        expect(chain.to(end_with)).to eq(%w[ cat cag cog dog ])
      end
    end
  end
end
