require 'rubygems'
require 'docker'
require 'serverspec'


container_id = ENV['KITCHEN_CONTAINER_ID'] || nil

if container_id.nil?
  puts 'No KITCHEN_CONTAINER_ID variable defined'
  exit 1
end

RSpec.configure do |config|
  # Use color in STDOUT
  config.color = true
  # Use color not only in STDOUT but also in pagers and files
  config.tty = true
  set :backend, :docker
  set :docker_container, container_id
end


