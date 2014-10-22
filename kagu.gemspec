Gem::Specification.new do |s|
  s.name = 'kagu'
  s.version = File.read("#{File.dirname(__FILE__)}/VERSION").strip
  s.platform = Gem::Platform::RUBY
  s.author = 'Alexis Toulotte'
  s.email = 'al@alweb.org'
  s.homepage = 'https://github.com/alexistoulotte/kagu'
  s.summary = 'API for iTunes'
  s.description = 'API to manage iTunes tracks and playlists'
  s.license = 'MIT'

  s.rubyforge_project = 'kagu'

  s.files = `git ls-files`.split("\n")
  s.test_files = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ['lib']

  s.add_dependency 'activesupport', '>= 4.1.0', '< 4.2.0'
  s.add_dependency 'applescript', '>= 1.0', '< 2.0'
  s.add_dependency 'htmlentities', '>= 4.3.0', '< 4.4.0'

  s.add_development_dependency 'byebug', '>= 3.2.0', '< 3.6.0'
  s.add_development_dependency 'rake', '>= 10.3.0', '< 10.4.0'
  s.add_development_dependency 'rspec', '>= 3.1.0', '< 3.2.0'
end
