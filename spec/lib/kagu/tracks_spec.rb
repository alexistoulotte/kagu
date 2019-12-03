require 'spec_helper'

describe Kagu::Tracks do

  let(:tracks) { Kagu::Tracks.new }

  describe '#each' do

    it 'all tracks must be correct path must be a file' do
      tracks.each do |track|
        expect(File.file?(track.path)).to be(true)
        expect(track).to be_a(Kagu::Track)
        expect(track.added_at).to be_a(Time)
        expect(track.album).to be_a(String)
        expect(track.album).to be_present
        expect(track.artist).to be_a(String)
        expect(track.artist).to be_present
        expect(track.exists?).to be(true)
        expect(track.genre).to be_a(String)
        expect(track.genre).to be_present
        expect(track.id).to be_a(String)
        expect(track.id.size).to be > 10
        expect(track.length).to be_an(Integer)
        expect(track.path.to_s).not_to include('file://')
        expect(track.path.to_s).to include('Music')
        expect(track.title).to be_a(String)
        expect(track.title).to be_present
        expect(track.year).to be_an(Integer)
        expect(track.year.to_s).to match(/\A\d{4}\z/)
      end
    end

    it 'does not fails if block is not given' do
      expect {
        expect(tracks.each).to be_nil
      }.not_to raise_error
    end

    it 'returns nil' do
      expect(tracks.each {}).to be_nil
    end

    it 'all tracks must exists and path should not include UTF-8-MAC charset' do
      tracks.each do |track|
        expect(track.path.to_s).not_to include("\u{65}\u{301}")
        expect(track.exists?).to be(true)
      end
    end

  end

end
