require 'spec_helper'

describe Kagu::Playlists do

  let(:library) { Kagu::Library.new }
  let(:playlists) { Kagu::Playlists.new(library) }

  describe '#each' do

    it 'playlists must contains at least 1 song and a name' do
      expect(playlists.count).to be > 5
      playlists.each do |playlist|
        expect(playlist.name).not_to eq('Bibliothèque')
        expect(playlist.name).not_to match(/\&#\d+;/)
        expect(playlist.name).to be_a(String)
        expect(playlist.name).to be_present
        expect(playlist.tracks.size).to be > 0
      end
    end

    it 'does not fails if block is not given' do
      expect {
        expect(playlists.each).to be_nil
      }.not_to raise_error
    end

    it 'returns nil' do
      expect(playlists.each { break }).to be_nil
    end

  end

  describe '#initialize' do

    it 'raise an error if library is nil' do
      expect {
        Kagu::Playlists.new(nil)
      }.to raise_error('Kagu::Playlists#library must be a library, nil given')
    end

  end

end
