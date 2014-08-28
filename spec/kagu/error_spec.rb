require 'spec_helper'

describe Kagu::Error do

  let(:error) { Kagu::Error.new('BAM!') }
  let(:original) { StandardError.new('BIM!') }

  describe '#message' do

    it 'is message set at initialization' do
      expect(error.message).to eq('BAM!')
    end

    it 'message is squished' do
      expect(Kagu::Error.new(" hello  \n world").message).to eq('hello world')
    end

    it 'default one if blank' do
      expect(Kagu::Error.new(" ").message).to eq('Kagu::Error')
    end

  end

  describe '#original' do

    it 'is nil by default' do
      expect(error.original).to be_nil
    end

    it 'is exception given at initialization' do
      expect(Kagu::Error.new(original).original).to be(original)
    end

    it 'sets message from original' do
      expect(Kagu::Error.new(original).message).to eq('BIM!')
    end

  end

end
