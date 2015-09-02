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
      expect(library.playlists.library).to be(library)
    end

  end

  describe '#tracks' do

    it 'returns a Tracks object' do
      expect(library.tracks).to be_a(Kagu::Tracks)
      expect(library.tracks.library).to be(library)
    end

  end

end
