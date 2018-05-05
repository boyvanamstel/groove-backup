#!/usr/bin/env ruby

require 'io/console'
require 'groovehq'

require_relative 'lib/backup'

access_token = ENV["GROOVEHQ_ACCESS_TOKEN"]
if access_token.nil?
  puts "Provide your Private Token:"
  access_token = STDIN.noecho(&:gets).chomp
end

client = GrooveHQ::Client.new(access_token)
storage = Backup::Storage.new('output', client)

storage.backup()

