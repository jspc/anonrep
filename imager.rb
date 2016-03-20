#!/usr/bin/env ruby

$LOAD_PATH << File.join(__FILE__, '..', 'lib')

require 'rsses'
require 'helpers'
require 'tweets'
require 'flickr_images'

require 'chatterbot/dsl'
require 'redis'

use_streaming
# FFFUUUCCCCKKKKKKK YYYOOOUUUU Future James
config_dir = ENV.fetch('DOCKER_MODE', 0).to_i == 1 ? '/config' : File.join(File.dirname(__FILE__), 'config')
config = YAML.load File.read( File.join(config_dir , 'config.yml') )

redis_host = ENV.fetch('REDIS_HOST', 'localhost')
redis_port = ENV.fetch('REDIS_PORT', 6379)

redis_object = Redis.new(host: redis_host, port: redis_port)

loop do
  t = AnonRep::Tweets.return_and_remove redis_object

  img = nil
  until img
    search_term = config['search_terms'].sample
    AnonRep::Helpers.log 'imager', "Search flickr for '#{search_term}'"

    while img.nil? or redis_object.smembers('flickr_images').include? img
      img = AnonRep::Flickr.image_search(search_term).sample
    end
    redis_object.sadd 'flickr_images', img
  end

  AnonRep::Helpers.log 'imager', "Downloading #{img}"
  img_io = AnonRep::Flickr.store img

  if t.nil?
    AnonRep::Helpers.log 'imager', 'Nothing to tweet'
  else
    begin
      client.update_with_media(t, img_io)
      AnonRep::Helpers.log 'imager', "Tweeted '#{t}' with #{img}"
    rescue Exception => e
      AnonRep::Helpers.log 'imager', e.message
    ensure
      img_io.close
      img_io.unlink
    end
  end

  sleep_time = rand(180*60) # Three hours
  AnonRep::Helpers.log 'imager', "Sleeping for #{sleep_time / 60} minutes prior to next tweet"
  sleep sleep_time
end
