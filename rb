#!/usr/bin/env ruby

require 'thor'
require 'fileutils'
require 'memcache_check'
require 'colorize'

class Rb < Thor

  no_commands do
    def highlight(mytext)
      puts "\e[41m#{mytext}\e[0m"
    end
  end

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

  desc 'updateall', 'Update Homebrew and other stuff'
  def updateall
    highlight "brew update"
    `brew update`
    highlight "brew upgrade"
    `brew upgrade`
    highlight "brew cask upgrade"
    `brew cask upgrade`
    highlight "brew upgrade --cleanup"
    `brew upgrade --cleanup`
    highlight "brew cleanup"
    `brew cleanup`
    highlight "brew doctor"
    `brew doctor`
    highlight "update-dotfiles"
    `curl https://raw.githubusercontent.com/mikeadmire/dotfiles/master/install.sh -o - | sh`
    highlight "update-home_bin"
    `curl https://raw.githubusercontent.com/mikeadmire/home_bin/master/install.sh -o - | sh`
  end
end

Rb.start
