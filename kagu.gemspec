Gem::Specification.new do |s|
  s.name = 'kagu'
  s.version = File.read("#{File.dirname(__FILE__)}/VERSION").strip
  s.platform = Gem::Platform::RUBY
  s.author = 'Alexis Toulotte'
  s.email = 'al@alweb.org'
  s.homepage = 'https://github.com/alexistoulotte/kagu'
  s.summary = 'API for macOS Music'
  s.description = 'API to manage macOS Music tracks and playlists'
  s.license = 'MIT'

  s.files = `git ls-files | grep -vE '^(spec/|test/|\\.|Gemfile|Rakefile)'`.split("\n")
  s.executables = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ['lib']

  s.required_ruby_version = '>= 2.0.0'

  s.add_dependency 'activesupport', '>= 4.1.0', '< 7.0.0'
  s.add_dependency 'addressable', '>= 2.7.0', '< 3.0.0'
  s.add_dependency 'applescript', '>= 1.0', '< 2.0'

  s.add_development_dependency 'byebug', '>= 3.2.0', '< 12.0.0'
  s.add_development_dependency 'rake', '>= 10.3.0', '< 14.0.0'
  s.add_development_dependency 'rspec', '>= 3.1.0', '< 3.11.0'
end
