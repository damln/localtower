module Localtower
end

# EXTERNAL GEM
require 'thor'
require 'active_link_to'

root = File.expand_path(File.dirname(__FILE__))
Dir["#{root}/localtower/*.rb"].sort.each { |file| require file }
Dir["#{root}/localtower/*/**/*.rb"].each { |file| require file }
