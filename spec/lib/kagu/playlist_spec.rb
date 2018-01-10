require 'spec_helper'

describe Kagu::Playlist do

  let(:library) { Kagu::Library.new }
  let(:playlist) { Kagu::Playlist.new(name: 'Best tracks', tracks: tracks) }
  let(:tracks) { library.tracks.take(15) }

  describe '#each' do

    it 'is delegated to tracks' do
      track = nil
      playlist.each do |t|
        track = t
        break
      end
      expect(track).to be_a(Kagu::Track)
    end

  end

  describe '#itunes_name=' do

    it 'set name and convert entities' do
      expect {
        playlist.send(:itunes_name=, 'Hello &amp; World')
      }.to change { playlist.name }.from('Best tracks').to('Hello & World')
    end

  end

  describe '#name' do

    it 'is set at initialization' do
      expect(Kagu::Playlist.new(name: 'Best tracks').name).to eq('Best tracks')
    end

    it 'is squished' do
      expect(Kagu::Playlist.new(name: "Best  \t tracks\n").name).to eq('Best tracks')
    end

    it 'is mandatory' do
      expect {
        Kagu::Playlist.new(name: ' ')
      }.to raise_error(Kagu::Error, 'Kagu::Playlist#name is mandatory')
    end

  end

  describe '#to_s' do

    it 'is name' do
      expect(Kagu::Playlist.new(name: 'Best tracks').to_s).to eq('Best tracks')
    end

  end

  describe '#tracks' do

    it 'is an empty array by default' do
      expect(Kagu::Playlist.new(name: 'Test').tracks).to eq([])
    end

    it 'is tracks given at initialization' do
      expect(Kagu::Playlist.new(name: 'Test', tracks: tracks).tracks).to eq(tracks)
    end

    it 'removes invalid tracks' do
      expect(Kagu::Playlist.new(name: 'Test', tracks: ['bar', [tracks.first], 'foo']).tracks).to eq([tracks.first])
    end

  end

end
