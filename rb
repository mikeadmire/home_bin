#!/usr/bin/env ruby

require 'thor'
require 'fileutils'
require 'memcache_check'
require 'colorize'

class Rb < Thor

  desc "sinatra PROJECT", "setup the directory structure for a new Sinatra project"
  def sinatra(name)
    FileUtils.mkdir "#{name}"
    FileUtils.cd "#{name}"
    FileUtils.mkdir %w(config lib public tmp views)
    FileUtils.touch('.gitignore')
    File.open('README', 'w') { |f| f.write "== Welcome to the #{name} project" }
    File.open('Gemfile', 'w') do |f|
      f.write "source 'https://rubygems.org'\n\n"
      f.write "gem 'sinatra'\n"
      f.write "gem 'shotgun'"
    end
    File.open("#{name}.rb", 'w') do |f|
      f.write "require 'sinatra'\n\n"
      f.write "get '/' do\n  \"Hello, world!\"\nend"
    end
    File.open('config.ru', 'w') do |f|
      f.write "require './#{name}'\n"
      f.write "run Sinatra::Application"
    end
  end

  desc "gem PROJECT", "Deprecated. Use `bundle gem PROJECT`."
  def gem(name)
    `bundle gem #{name}`
  end

  desc 'memcachetest [-h hostname] [-n # of times]',
    'Run a series of set and get commands against a Memcached server and provide basic benchmarking'
  method_options %w( host -h ) => 'localhost'
  method_options %w( number -n ) => 50
  def memcachetest

    # command line options
    host = options[:host]
    number = options[:number]

    memcheck = MemcacheCheck::Checker.new(host)
    passes, fails, time = memcheck.start(number)

    puts "Benchmark results for host: " + "#{host}".colorize(:cyan)
    print "#{number}".colorize(:cyan)
    print " checks run in: " 
    print "%.5f".colorize(:yellow) % time.real 
    puts " seconds"
    puts "#{passes}".colorize(:cyan) + " passes"
    puts "#{fails}".colorize(:cyan) + " failures"
  end

end

Rb.start
