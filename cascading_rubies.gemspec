Gem::Specification.new do |s|
  s.name = "cascading_rubies"
  s.version = "0.1.0"
  s.author = "Tim Morgan"
  s.email = "tim@timmorgan.org"
  s.homepage = "http://github.com/seven1m/cascading_rubies"
  s.summary = "Ruby DSL for generating CSS."
  s.files = %w(README.markdown lib/cascading_rubies.rb bin/rcss test/test_cascading_rubies.rb example/example.rcss)
  s.require_path = "lib"
  s.has_rdoc = false
  s.executables = %w(rcss)
end
