require 'spec_helper'

describe Kagu::Tracks do

  let(:library) { Kagu::Library.new }
  let(:tracks) { Kagu::Tracks.new(library) }

  describe '#each' do

    it 'most of tracks must be correct path must be a file' do
      tracks.take(100).each do |track|
        expect(File.file?(track.path)).to be(true)
        expect(track).to be_a(Kagu::Track)
        expect(track.added_at).to be_a(Time)
        expect(track.album).to be_a(String)
        expect(track.album).to be_present
        expect(track.artist).to be_a(String)
        expect(track.artist).to be_present
        expect(track.genre).to be_a(String)
        expect(track.genre).to be_present
        expect(track.id).to be_an(Integer)
        expect(track.length).to be_an(Integer)
        expect(track.path).not_to include('file://')
        expect(track.path).to include('Music')
        expect(track.title).to be_a(String)
        expect(track.title).to be_present
      end
    end

    it 'does not fails if block is not given' do
      expect {
        expect(tracks.each).to be_nil
      }.not_to raise_error
    end

    it 'returns nil' do
      expect(tracks.each { break }).to be_nil
    end

  end

  describe '#library' do

    it 'is library given at initialization' do
      expect(tracks.library).to be(library)
    end

    it 'raise an error if library is nil' do
      expect {
        Kagu::Tracks.new(nil)
      }.to raise_error(ArgumentError, 'Kagu::Tracks#library must be a library, nil given')
    end

  end

end
