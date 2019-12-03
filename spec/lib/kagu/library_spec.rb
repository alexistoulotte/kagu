require 'spec_helper'

describe Kagu::Library do

  let(:library) { Kagu::Library.new }

  describe '#finder' do

    it 'returns a Kagu::Finder instance' do
      expect(library.finder).to be_a(Kagu::Finder)
    end

    it 'options can be specified' do
      expect(library.finder(replacements: { 'foo' => 'bar' }).replacements).to eq([{ 'foo' => 'bar' }])
    end

  end

  describe '#playlists' do

    it 'returns a Playlists object' do
      expect(library.playlists).to be_a(Kagu::Playlists)
    end

  end

  describe '#tracks' do

    it 'returns a Tracks object' do
      expect(library.tracks).to be_a(Kagu::Tracks)
    end

  end

end
