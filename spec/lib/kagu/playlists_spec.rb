require 'spec_helper'

describe Kagu::Playlists do

  let(:playlists) { Kagu::Playlists.new }

  describe '#each' do

    it 'playlists must contains at least 1 song and a name' do
      expect(playlists.count).to be > 5
      playlists.each do |playlist|
        expect(playlist.name).not_to eq('Bibliothèque')
        expect(playlist.name).not_to match(/\&#\d+;/)
        expect(playlist.name).to be_a(String)
        expect(playlist.name).to be_present
      end
    end

    it 'does not fails if block is not given' do
      expect {
        expect(playlists.each).to be_nil
      }.not_to raise_error
    end

    it 'returns nil' do
      expect(playlists.each {}).to be_nil
    end

  end

end
