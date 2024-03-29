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
        allow(other).to receive(:length).and_return(track.length - 1)
      }.to change { track <=> other }.from(0).to(1)
    end

    it 'is nil if length is nil' do
      allow(track).to receive(:length).and_return(nil)
      expect(track <=> other).to be_nil
    end

    it 'is nil if other track length is nil' do
      allow(other).to receive(:length).and_return(nil)
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
      }.to raise_error(Kagu::Error, /^Kagu::Track#added_at is mandatory for.+/)
    end

  end

  describe '#album' do

    it 'is correct' do
      expect(track.album).to be_present
    end

    it 'is is squished' do
      track.send(:album=, " Life Is   \r Peachy  \n")
      expect(track.album).to eq('Life Is Peachy')
    end

  end

  describe '#artist' do

    it 'is artist' do
      expect(track.album).to be_present
    end

    it 'is is squished' do
      track.send(:artist=, " Benny   \r Page  \n")
      expect(track.artist).to eq('Benny Page')
    end

  end

  describe '#bpm' do

    it 'is nil if invalid' do
      track.send(:bpm=, '42a')
      expect(track.bpm).to be_nil
    end

    it 'is nil if 0' do
      track.send(:bpm=, '0')
      expect(track.bpm).to be_nil
    end

    it 'is nil if negative' do
      track.send(:bpm=, '-1')
      expect(track.bpm).to be_nil
    end

    it 'is an integer' do
      track.send(:bpm=, '143')
      expect(track.bpm).to be(143)
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

  describe '#exists_on_disk?' do

    it 'is false if path is nil' do
      expect {
        allow(track).to receive(:path).and_return(nil)
      }.to change { track.exists_on_disk? }.from(true).to(false)
    end

    it 'is true if path is a file' do
      expect {
        allow(track).to receive(:path).and_return(Pathname.new('/tmp/foo.mp3'))
      }.to change { track.exists_on_disk? }.from(true).to(false)
    end

    it 'is false if path is a directory' do
      expect {
        allow(track).to receive(:path).and_return(Pathname.new('/tmp'))
      }.to change { track.exists_on_disk? }.from(true).to(false)
    end

  end

  describe '#genre' do

    it 'is correct' do
      expect(track.genre).to be_a(String)
      expect(track.genre).to be_present
    end

  end

  describe '#hash' do

    let(:other) { track.dup }

    it 'is an integer' do
      expect(track.hash).to be_a(Integer)
    end

    it 'it differs if artist differs' do
      expect {
        allow(other).to receive(:artist).and_return('Foo')
      }.to change { track.hash == other.hash }.from(true).to(false)
    end

    it 'it differs if title differs' do
      expect {
        allow(other).to receive(:title).and_return('Bar')
      }.to change { track.hash == other.hash }.from(true).to(false)
    end

  end

  describe '#id' do

    it 'is correct' do
      expect(track.id).to be_a(String)
      expect(track.id).to be_present
    end

    it 'raise an error if not specified' do
      expect {
        Kagu::Track.new(attributes.except(:id))
      }.to raise_error(Kagu::Error, /^Kagu::Track#id is mandatory for.+/)
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
      }.to raise_error(Kagu::Error, /^Kagu::Track#length is mandatory for.+/)
    end

  end

  describe '#path' do

    it 'is correct' do
      expect(track.path).to be_a(Pathname)
      expect(track.path.file?).to be(true)
    end

    it 'does not raise an error if not specified' do
      track = Kagu::Track.new(attributes.except(:path))
      expect(track.path).to be_nil
    end

    it 'does not raise an error if not found' do
      expect {
        Kagu::Track.new(attributes.merge(path: '/tmp/bar.mp3'))
      }.not_to raise_error
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

  describe '#year' do

    it 'is an integer' do
      expect(track.year).to be_an(Integer)
    end

    it 'is correct' do
      expect(track.year.to_s).to match(/\A\d{4}\z/)
    end

    it 'is nil if negative' do
      track.send(:year=, -1)
      expect(track.year).to be_nil
    end

    it 'is nil if invalid' do
      track.send(:year=, 20_434)
      expect(track.year).to be_nil
    end

    it 'can be < 1000' do
      track.send(:year=, 942)
      expect(track.year).to be(942)
    end

    it 'can be set as string' do
      track.send(:year=, '1984')
      expect(track.year).to be(1984)
    end

    it 'is nil if string is invalid' do
      track.send(:year=, '1984 ')
      expect(track.year).to be_nil
    end

  end

end
