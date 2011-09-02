# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "kingkong/version"

Gem::Specification.new do |s|
  s.name        = "kingkong"
  s.version     = KingKong::VERSION
  s.authors     = ["Brad Gessler"]
  s.email       = ["brad@bradgessler.com"]
  s.homepage    = ""
  s.summary     = %q{Build complex network application health checks with Ruby and EventMachine}
  s.description = %q{Have you ever wanted to shoot a message throught Twitter, have your app pick it up, do some work on it, and report how long it takes? KingKong makes it slightly easier to do this with a DSL for writing custom pings and by providing basic reporting facilities that plug into graphing applications like Munin.}

  s.rubyforge_project = "kingkong"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  # specify any dependencies here; for example:
  # s.add_development_dependency "rspec"
  s.add_runtime_dependency "eventmachine"
end