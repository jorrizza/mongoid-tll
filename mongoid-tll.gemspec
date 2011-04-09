spec = Gem::Specification.new do |s|
  s.name = 'mongoid-tll'
  s.version = '0.0.1'
  s.summary = 'Top linked list plugin for Mongoid'
  s.platform = Gem::Platform::RUBY
  s.description = 'Creates a (doubly) top linked list out of your documents. Every change makes a new revision. Basically a read optimized versioning system.'
  s.author = 'Joris van Rooij'
  s.email = 'jorrizza@jrrzz.net'
  s.homepage = 'https://github.com/jorrizza/mongoid-tll'
  s.add_dependency('mongoid', '>= 2.0.0')

  s.files = %w[
  lib
  lib/mongoid
  lib/mongoid/tll.rb
  LICENSE
  README.md
  ]
  
  s.test_files = %w[
  test
  test/mongoid-tll.rb
  ]
end
