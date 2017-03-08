module Localtower
end

# EXTERNAL GEM
require 'thor'
require 'active_link_to'
require 'zip'
require 'pg'
require 'sqlite3'

begin
  require "pry"
rescue Exception => e
  puts "No Pry."
end

root = File.expand_path(File.dirname(__FILE__))
Dir["#{root}/localtower/*.rb"].sort.each { |file| require file }
Dir["#{root}/localtower/generators/**/*.rb"].each { |file| require file }
