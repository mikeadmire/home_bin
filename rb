#!/usr/bin/env ruby

require 'ostruct'
require 'thor'
require 'fileutils'
require 'dalli'
require 'benchmark'
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

    memcache_test = MemcacheTest.new(host)
    key = memcache_test.generate_key
    value = GetTestData.new

    time = Benchmark.measure do
      number.times do
        memcache_test.set(key, value)
        memcache_test.get(key)
      end
    end
    puts "Benchmark results for host: " + "#{host}".colorize(:cyan)
    print "#{number}".colorize(:cyan)
    print " actions completed in: " 
    print "%.5f".colorize(:yellow) % time.real 
    puts " seconds"
  end

end


private

class MemcacheTest

  def initialize(host)
    @memcache = Dalli::Client.new("#{host}:11211")
  end

  def generate_key
    key = "mike#{Time.now.strftime("%s%L")}"
  end

  def set(key, value)
    @memcache.set(key, Marshal.dump(value))
  end

  def get(key)
    Marshal.load(@memcache.get(key))
  end

end

class GetTestData
  data = OpenStruct.new
  data.name = 'Test Data'
  data.website = 'http://www.example.com/'
  data.city = 'Test City'
  data.state = 'Anywhere State'
  data
end


Rb.start
