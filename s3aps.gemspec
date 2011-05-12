# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "s3aps/version"

Gem::Specification.new do |s|
  s.name        = "s3aps"
  s.version     = S3aps::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Bill Horsman"]
  s.email       = ["bill@logicalcobwebs.com"]
  s.homepage    = "http://github.com/billhorsman/s3aps"
  s.summary     = "s3aps-#{S3aps::VERSION}"
  s.description = "Synchronize between S3 bucket and filesystem"

  s.required_rubygems_version = ">= 1.3.6"

  s.add_development_dependency "bundler", ">= 1.0.0"
  s.add_runtime_dependency "right_aws"

  s.files        = `git ls-files`.split("\n")
  s.executables  = `git ls-files`.split("\n").map{|f| f =~ /^bin\/(.*)/ ? $1 : nil}.compact
  s.require_path = 'lib'
end
