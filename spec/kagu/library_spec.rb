require 'spec_helper'

describe Kagu::Library do

  let(:library) { Kagu::Library.new }

  describe '#initialize' do

    it 'is correct by default' do
      expect(library.path).to eq("#{ENV['HOME']}/Music/iTunes/iTunes Music Library.xml")
    end

    it 'raise an error if directory' do
      expect {
        Kagu::Library.new('/tmp')
      }.to raise_error(Kagu::Error, 'No such file: "/tmp"')
    end

    it "raise an error if file can't be found" do
      expect {
        Kagu::Library.new('/tmp/bar.foo.baz')
      }.to raise_error(Kagu::Error, 'No such file: "/tmp/bar.foo.baz"')
    end

  end

  describe '#playlists' do

    it 'returns a Playlists object' do
      expect(library.playlists).to be_a(Kagu::Playlists)
      expect(library.playlists.library).to be(library)
    end

  end

  describe '#tracks' do

    it 'returns a Tracks object' do
      expect(library.tracks).to be_a(Kagu::Tracks)
      expect(library.tracks.library).to be(library)
    end

    it 'path must exists and not include UTF-8-MAC charset' do
      library.tracks.each do |track|
        expect(track.path).not_to include("\u{65}\u{301}")
        expect(File.file?(track.path)).to be(true)
      end
    end

  end

end
