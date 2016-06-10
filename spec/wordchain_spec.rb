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
    Chain.new(
      dictionary: dictionary,
      start_with: start_with, end_with: end_with
    ) 
  end

  context 'with a simple dictionary' do
    let(:dictionary) do
      Dictionary.new(entries: %w[ star stag ruby rubs coal robs rods rode code cord ])
    end

    let(:start_with) { 'ruby' }
    let(:end_with) { 'code' }

    it 'should find candidates for next element of chain' do
      expect(chain.candidates_for('star')).to eql(['stag'])
      expect(chain.candidates_for('boat')).to eql([])
    end

    it 'should assemble the chain' do
      expect(subject.construct).to eq(%w[ ruby rubs robs rods rode code ])
    end
  end

  context 'with a real dictionary' do
    let(:dictionary) { Dictionary.new }
    let(:start_with) { 'lead' }
    let(:end_with) { 'gold' }
    it 'should assemble the chain' do
      expect(subject.construct).to eq(%w[ lead load goad gold ])
    end
  end
end
