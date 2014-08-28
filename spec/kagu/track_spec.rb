require 'spec_helper'

describe Kagu::Track do

  let(:attributes) { { added_at: track.added_at, album: track.album, artist: track.artist, id: track.id, length: track.length, path: track.path, title: track.title } }
  let(:library) { Kagu::Library.new }
  let(:track) { library.tracks.first }

  describe '#==' do

    let(:other) { track.dup }

    it 'is false if not a track' do
      expect(track == 'foo').to be(false)
    end

    it 'is false if artist differs' do
      expect {
        allow(other).to receive(:artist).and_return('Foo')
      }.to change { track == other }.from(true).to(false)
    end

    it 'is false if title differs' do
      expect {
        allow(other).to receive(:title).and_return('Bar')
      }.to change { track == other }.from(true).to(false)
    end

    it 'is false if length differs' do
      expect {
        allow(other).to receive(:length).and_return(track.length - 5)
      }.to change { track == other }.from(true).to(false)
    end

    it 'is true if length differs just a little' do
      expect {
        allow(other).to receive(:length).and_return(track.length - 2)
      }.not_to change { track == other }
    end

    it 'is true if album differs' do
      expect {
        allow(other).to receive(:album).and_return('Baz')
      }.not_to change { track == other }
    end

  end

  describe '#<=>' do

    let(:other) { track.dup }

    it 'compares tracks lengths' do
      expect {
        allow(other).to receive(:added_at).and_return(1.day.from_now)
      }.to change { track <=> other }.from(0).to(-1)
    end

    it 'is nil if added_at is nil' do
      allow(track).to receive(:added_at).and_return(nil)
      expect(track <=> other).to be_nil
    end

    it 'is nil if other track added_at is nil' do
      allow(other).to receive(:added_at).and_return(nil)
      expect(track <=> other).to be_nil
    end

    it 'is nil if other is not a track' do
      expect(track <=> '').to be_nil
    end

  end

  describe '#added_at' do

    it 'returns a time' do
      expect(track.added_at).to be_a(Time)
    end

    it 'return a time in utc' do
      expect(track.added_at.zone).to eq('UTC')
    end

    it 'raise an error if not specified' do
      expect {
        Kagu::Track.new(attributes.except(:added_at))
      }.to raise_error(Kagu::Error, 'Kagu::Track#added_at is mandatory')
    end

  end

  describe '#album' do

    it 'is is squished' do
      track.send(:album=, " Life Is   \r Peachy  \n")
      expect(track.album).to eq('Life Is Peachy')
    end

  end

  describe '#artist' do

    it 'is is squished' do
      track.send(:artist=, " Benny   \r Page  \n")
      expect(track.artist).to eq('Benny Page')
    end

  end

  describe '#eql?' do

    it 'is true for same object' do
      expect(track.eql?(track)).to be(true)
    end

    it 'is true if == returns true' do
      other = track.dup
      expect {
        allow(track).to receive(:==).and_return(false)
      }.to change { track.eql?(other) }.from(true).to(false)
    end

  end

  describe '#genre' do

    it 'is correct' do
      expect(track.genre).to be_a(String)
      expect(track.genre).to be_present
    end

  end

  describe '#id' do

    it 'is correct' do
      expect(track.id).to be_an(Integer)
      expect(track.id).to be > 0
    end

    it 'raise an error if not specified' do
      expect {
        Kagu::Track.new(attributes.except(:id))
      }.to raise_error(Kagu::Error, 'Kagu::Track#id is mandatory')
    end

  end

  describe '#itunes_name=' do

    it 'sets title with entities decoded' do
      expect {
        track.send(:itunes_name=, 'Racing &amp; Green')
      }.to change { track.title }.to('Racing & Green')
    end

  end

  describe '#length' do

    it 'is correct' do
      expect(track.length).to be_an(Integer)
      expect(track.length).to be > 0
    end

    it 'raise an error if not specified' do
      expect {
        Kagu::Track.new(attributes.except(:length))
      }.to raise_error(Kagu::Error, 'Kagu::Track#length is mandatory')
    end

  end

  describe '#path' do

    it 'is correct' do
      expect(track.path).to be_a(String)
      expect(File.file?(track.path)).to be(true)
    end

    it 'raise an error if not specified' do
      expect {
        Kagu::Track.new(attributes.except(:path))
      }.to raise_error(Kagu::Error, 'Kagu::Track#path is mandatory')
    end

    it 'raise an error if not found' do
      expect {
        Kagu::Track.new(attributes.merge(path: '/tmp/bar.mp3'))
      }.to raise_error(Kagu::Error, 'No such file: "/tmp/bar.mp3"')
    end

    it 'raise an error if not a file' do
      expect {
        Kagu::Track.new(attributes.merge(path: '/tmp'))
      }.to raise_error(Kagu::Error, 'No such file: "/tmp"')
    end

  end

  describe '#relative_path' do

    it 'is correct' do
      expect(track.relative_path(ENV['HOME'])).to eq(track.path.gsub("#{ENV['HOME']}/", ''))
    end

    it 'is full path if not starting with given path' do
      expect(track.relative_path('/Users/john')).to eq(track.path)
    end

  end

  describe '#title' do

    it 'is is squished' do
      track.send(:title=, " Racing   \r Green  \n")
      expect(track.title).to eq('Racing Green')
    end

  end

  describe '#to_s' do

    it 'is "artist - title"' do
      expect(track.to_s).to eq("#{track.artist} - #{track.title}")
    end

  end

end
