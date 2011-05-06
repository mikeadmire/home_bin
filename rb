#!/usr/bin/env ruby

require 'thor'
require 'fileutils'

class Rb < Thor


######## <Sinatra> ########
  @@sinatra_file_head = <<EOS
require 'sinatra'

get '/' do
  "Hello, world!"
end
EOS

  desc "sin PROJECT", "setup the directory structure for a new Sinatra project"
#  method_options :forcefully => :boolean
  def sin(name)
    FileUtils.mkdir "#{name}"
    FileUtils.cd "#{name}"
    FileUtils.mkdir %w(config lib public tmp views)
    File.open("#{name}.rb", 'w') { |f| f.write @@sinatra_file_head }
    File.open('Gemfile', 'w') { |f| f.write "source 'http://rubygems.org'" }
    File.open('README', 'w') { |f| f.write "== Welcome to the #{name} project" }
    File.open('.gitignore', 'w') { |f| f.write "*.swp" }
    File.open('.rvmrc', 'w') { |f| f.write "rvm 1.9.2" }
    File.open('config.ru', 'w') { |f|
      f.write "require './#{name}'\n"
      f.write "run Sinatra::Application"
    }
  end
######## </Sinatra> ########


######## <RubyGems> ########
  @@rakefile = <<EOS
require 'rubygems'
require 'rspec/core/rake_task'
require 'rake/gempackagetask'

task :default => [ :spec, :gem ]

RSpec::Core::RakeTask.new do |spec|
    spec.pattern = 'spec/**/*_spec.rb'
      spec.rspec_opts = ['--backtrace']
end

gem_spec = Gem::Specification.new do |s|
  s.name = 'Replace with app name'
  s.version = '0.0.1'
  s.authors = ['Mike Admire']
  s.date = %q{2011-03-16}
  s.description = 'Replace with description'
  s.summary = s.description
  s.email = 'mike@admire.org'
  s.files = ['README','lib/APP_NAME.rb','spec/APP_NAME_spec.rb']
  s.homepage = 'http://mikeadmire.com'
end

Rake::GemPackageTask.new( gem_spec ) do |t|
  t.need_zip = true
end
EOS

  desc "gem PROJECT", "setup the directory structure for a new gem"
  def gem(name)
    FileUtils.mkdir "#{name}"
    FileUtils.cd "#{name}"
    FileUtils.mkdir %w(lib pkg spec spec/rake)
    FileUtils.touch "lib/#{name}.rb"
    File.open("spec/#{name}_spec.rb", 'w') { |f| f.write "require 'spec_helper'\n\ndescribe '#{name}' do\n\s\spending\nend" }
    File.open('spec/spec_helper.rb', 'w') { |f| f.write "require './lib/#{name}'" }
    File.open('README', 'w') { |f| f.write "== Welcome to the #{name} project" }
    File.open('.gitignore', 'w') { |f| f.write "*.swp" }
    File.open('.rvmrc', 'w') { |f| f.write "rvm 1.9.2" }
    File.open('Rakefile', 'w') { |f| f.write @@rakefile }
    File.open('Gemfile', 'w') { |f| f.write "source 'http://rubygems.org'\n\ngem 'rake'\ngem 'rspec'" }
  end
######## </RubyGems> ########


  desc "hello", "say hello"
  def hello
    puts "Hello"
  end


end

Rb.start
