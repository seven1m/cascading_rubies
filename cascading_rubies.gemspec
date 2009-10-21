Gem::Specification.new do |s|
  s.name = "cascading_rubies"
  s.version = "0.2.3"
  s.author = "Tim Morgan"
  s.email = "tim@timmorgan.org"
  s.homepage = "http://seven1m.github.com/cascading_rubies/"
  s.summary = "Ruby DSL for generating CSS."
  s.files = %w(README.rdoc lib/cascading_rubies.rb lib/blankslate.rb bin/rcss test/test_cascading_rubies.rb example/example.rcss example/block_example_1.rcss example/block_example_2.rcss example/no_block_example.rcss)
  s.require_path = "lib"
  s.has_rdoc = true
  s.executables = %w(rcss)
end
