require 'spec_helper'

describe Kagu::Finder do

  let(:finder) { Kagu::Finder.new }

  describe '.replace' do

    it 'replace given value with replacements' do
      expect(Kagu::Finder.replace('Hello World!', 'World' => 'John', 'Hello' => 'Bye')).to eq('Bye John!')
    end

    it 'is case sensitive' do
      expect(Kagu::Finder.replace('Hello World!', 'world' => 'John', 'Hello' => 'Bye')).to eq('Bye World!')
    end

    it 'replace given value with some regexp' do
      expect(Kagu::Finder.replace('Hello World!', 'World' => 'John', /l+/ => 'i')).to eq('Heio John!')
    end

    it 'returns nil if blank' do
      expect(Kagu::Finder.replace('    ', 'world' => 'John', 'Hello' => 'Bye')).to be_nil
    end

    it 'accepts arrays as replacements' do
      expect(Kagu::Finder.replace('Hello World!', [%w(World John), %w(Hello Bye)])).to eq('Bye John!')
    end

  end

  describe '.transliterate' do

    it 'removes accents' do
      expect(Kagu::Finder.transliterate('éàlôrs')).to eq('ealors')
    end

    it 'removes consecutive white spaces' do
      expect(Kagu::Finder.transliterate(" hello   \t world\n  ")).to eq('hello world')
    end

    it 'converts value to lower case' do
      expect(Kagu::Finder.transliterate('Hello World')).to eq('hello world')
    end

    it 'removes nil if blank' do
      expect(Kagu::Finder.transliterate(' ')).to be_nil
    end

  end

  describe '#find' do

    it 'returns some tracks' do
      tracks = finder.find(artist: 'korn', title: 'blind')
      expect(tracks).to be_an(Array)
      expect(tracks.first).to be_a(Kagu::Track)
      expect(tracks.first.title).to match(/blind/i)
    end

    it 'returns nothing if artist is blank' do
      expect(finder.find(title: 'blind')).to be_empty
    end

    it 'returns nothing if title is blank' do
      expect(finder.find(artist: 'korn')).to be_empty
    end

    it 'returns nothing if artist match an artist and a track' do
      expect(finder.find(artist: 'korn blind')).to be_empty
    end

    it 'artist and title can be specified as string' do
      expect(finder.find('artist' => 'KoRn', 'title' => 'Ball Tongue').first).to be_a(Kagu::Track)
    end

    it 'returns an array of array of tracks if there is some replacements' do
      finder.reload(replacements: { 'ball tongue' => 'blind' })
      results = finder.find(artist: 'korn', title: 'blind')
      expect(results.size).to eq(2)
      expect(results.first).to be_an(Array)
      expect(results.first.first.title).to match(/blind/i)
      expect(results.second.first.title).to match(/ball tongue/i)
    end

    it 'replacements are working with given attributes' do
      finder.reload(replacements: { 'hello world' => 'blind' })
      results = finder.find(artist: 'korn', title: 'hello world')
      expect(results.size).to eq(1)
      expect(results.first.first).to be_a(Kagu::Track)
      expect(results.first.first.title).to match(/blind/i)
    end

    it 'put at first position the exact matches from given attributes' do
      finder.reload(replacements: { 'ball tongue' => 'blind' })
      results = finder.find(artist: 'korn', title: 'ball tongue')
      expect(results.size).to eq(2)

      expect(results.first).not_to be_empty
      results.first.each do |track|
        expect(track.title).to match(/ball tongue/i)
      end

      expect(results.second).not_to be_empty
      results.second.each do |track|
        expect(track.title).to match(/blind/i)
      end
    end

    it 'does not include ignored tracks' do
      expect {
        finder.reload(ignored: 'korn blind')
      }.to change { finder.find(artist: 'korn', title: 'blind').size }.to(0)
      expect(finder.find(artist: 'korn', title: 'ball tongue')).not_to be_empty
    end

    it 'does not include ignored tracks for each digest' do
      finder.reload(replacements: { 'blind' => 'foo' })
      expect {
        finder.reload(ignored: 'korn foo', replacements: { 'blind' => 'foo' })
      }.to change { finder.find(artist: 'korn', title: 'blind').size }.to(0)
    end

    it 'finds for some tracks with replacements as regexp' do
      finder.reload(replacements: { /subsonik (\d+)/ => 'subsonik podcast \\1' })
      results = finder.find(artist: 'subsonik', title: '002')
      expect(results.size).to eq(1)
      expect(results.first.first.title).to match(/podcast 002/i)
    end

    it 'does not fails if it does not match last replacements' do
      finder.reload(replacements: [{ /subsonik (\d+)/ => 'subsonik podcast \\1' }, { /\s+/ => '' }])
      results = finder.find(artist: 'subsonik', title: '002')
      expect(results.size).to eq(1)
      expect(results.first.first.title).to match(/podcast 002/i)
    end

  end

  describe '#ignored' do

    it 'can be set as an array of string' do
      expect {
        finder.reload(ignored: %w(test foo))
      }.to change { finder.ignored }.from([]).to(%w(test foo))
    end

    it 'can be set as a simple string' do
      expect {
        finder.reload(ignored: 'test')
      }.to change { finder.ignored }.from([]).to(['test'])
    end

    it 'is transliterated' do
      expect {
        finder.reload(ignored: ['testé  HeLLo World', 'foo'])
      }.to change { finder.ignored }.from([]).to(['teste hello world', 'foo'])
    end

    it 'can be set from a track' do
      expect {
        finder.reload(ignored: [finder.find(artist: 'KoRn', title: 'Blind').first])
      }.to change { finder.ignored }.from([]).to(['korn blind'])
    end

    it 'can be set from an hash (as string keys)' do
      expect {
        finder.reload(ignored: { 'artist' => 'KoRn', 'title' => 'Blind' })
      }.to change { finder.ignored }.from([]).to(['korn blind'])
    end

    it 'can be set from an hash (with symbol keys)' do
      expect {
        finder.reload(ignored: { artist: 'KoRn', title: 'Blind' })
      }.to change { finder.ignored }.from([]).to(['korn blind'])
    end

    it 'removes duplicates' do
      expect {
        finder.reload(ignored: ['test', 'Foo ', 'foo', 'TEST'])
      }.to change { finder.ignored }.from([]).to(%w(test foo))
    end

  end

  describe '#ignored?' do

    it 'is false if nil is given' do
      expect(finder.ignored?(nil)).to be(false)
    end

    it 'is true if at least one digest is ignored' do
      finder.reload(replacements: { 'hello' => 'world' }, ignored: 'korn world')
      expect(finder.ignored?(double(artist: 'korn', title: 'blind'))).to be(false)
      expect(finder.ignored?(double(artist: 'korn', title: 'hello'))).to be(true)
      expect(finder.ignored?(double(artist: 'korn', title: 'world'))).to be(true)
      expect(finder.ignored?(double(artist: 'korn', title: 'hellow'))).to be(false)
    end

  end

  describe '#reload' do

    it 'sets replacements' do
      expect {
        finder.reload(replacements: { 'foo' => 'bar' })
      }.to change { finder.replacements }.from([]).to([{ 'foo' => 'bar' }])
    end

    it 'removes replacements' do
      finder.reload(replacements: { 'foo' => 'bar' })
      expect {
        finder.reload
      }.to change { finder.replacements }.to([])
    end

    it 'removes ignored' do
      finder.reload(ignored: 'foo')
      expect {
        finder.reload
      }.to change { finder.ignored }.to([])
    end

    it 'returns finder' do
      expect(finder.reload).to be(finder)
    end

    it 'reload tracks' do
      expect {
        finder.reload(replacements: { /\./ => '' })
      }.to change { finder.find(artist: 'korn', title: 'adidas').present? }.from(false).to(true)
    end

    it 'returns finder' do
      expect(finder.reload).to be(finder)
    end

  end

  describe '#reload!' do

    it 'invokes reload' do
      argument = { 'foo' => 'bar' }
      expect(finder).to receive(:reload).with(argument)
      finder.reload!(argument)
    end

    it 'removes tracks cache' do
      finder.find(artist: 'korn', title: 'blind')
      expect {
        finder.reload!
      }.to change { finder.instance_variable_get(:@tracks) }.to(nil)
    end

    it 'returns finder' do
      expect(finder.reload!).to be(finder)
    end

  end

  describe '#replacements' do

    it 'can be ommited' do
      expect(finder.reload.replacements).to eq([])
    end

    it 'can be specified as regexp' do
      expect(finder.reload(replacements: { /bar/ => 'foo' }).replacements).to eq([/bar/ => 'foo'])
    end

    it 'can be specified with a string as key' do
      expect(finder.reload('replacements' => { 'foo' => 'bar' }).replacements).to eq([{ 'foo' => 'bar' }])
    end

    it 'can be specified as hash' do
      expect(finder.reload(replacements: { 'foo' => 'bar' }).replacements).to eq([{ 'foo' => 'bar' }])
    end

    it 'can be specified as array of hashes' do
      expect(finder.reload(replacements: [{ 'foo' => 'bar' }, { 'titi' => 'toto' }]).replacements).to eq([{ 'foo' => 'bar' }, { 'titi' => 'toto' }])
    end

    it 'can be specified as array of array' do
      expect(finder.reload(replacements: [%w(foo bar), ['titi' => 'toto']]).replacements).to eq([%w(foo bar), ['titi' => 'toto']])
    end

    it 'raise an error if a string is given' do
      expect {
        finder.reload(replacements: 'foo')
      }.to raise_error('Replacements must be an array or a hash, "foo" given')
    end

    it 'raise an error if it contains something else than an hash or array' do
      expect {
        finder.reload(replacements: [{ 'foo' => 'bar' }, 'titi'])
      }.to raise_error('Replacements must contain only hashes or arrays')
    end

  end

end
