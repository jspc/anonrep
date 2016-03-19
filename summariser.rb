#!/usr/bin/env ruby

$LOAD_PATH << File.join(__FILE__, '..', 'lib')

require 'chatterbot/dsl'
require 'helpers'
require 'redis'
require 'rsses'
require 'yaml'

max_link_limit = client.configuration.short_url_length

# FFFUUUCCCCKKKKKKK YYYOOOUUUU Future James
config_dir = ENV.fetch('DOCKER_MODE', 0).to_i == 1 ? '/config' : File.join(File.dirname(__FILE__), 'config')
config = YAML.load File.read( File.join(config_dir , 'config.yml') )

redis_host = ENV.fetch('REDIS_HOST', 'localhost')
redis_port = ENV.fetch('REDIS_PORT', 6379)

redis_object = Redis.new(host: redis_host, port: redis_port)

loop do
  AnonRep::Helpers.log 'summariser', 'Starting summary spider'
  summaries = AnonRep::RSS.iterate config['feeds'], max_link_limit, redis_object
  AnonRep::Helpers.log 'summariser', 'Spidering complete'

  unless summaries.empty?
    t = summaries.sample
    tweet t
    AnonRep::Helpers.log 'summariser', "Tweeted '#{t}'"
  end

  sleep_time = rand(90*60) # An hour and a half
  AnonRep::Helpers.log 'summariser', "Sleeping for #{sleep_time / 60} minutes prior to next tweet"
  sleep sleep_time
end
