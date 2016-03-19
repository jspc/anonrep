#!/usr/bin/env ruby

$LOAD_PATH << File.join(__FILE__, '..', 'lib')

require 'rsses'
require 'helpers'

require 'chatterbot/dsl'
require 'redis'

use_streaming

redis_host = ENV.fetch('REDIS_HOST', 'localhost')
redis_port = ENV.fetch('REDIS_PORT', 6379)

redis_object = Redis.new(host: redis_host, port: redis_port)
set_name = 'markov_tweets'

loop do
  t = redis_object.srandmember(set_name).force_encoding('UTF-8')

  if t.nil?
    AnonRep::Helpers.log 'markov_tweeter', 'Nothing to tweet'
  else
    begin
      tweet t
      redis_object = redis_object.srem set_name, t
      AnonRep::Helpers.log 'markov_tweeter', "Tweeted '#{t}'"
    rescue Exception => e
      AnonRep::Helpers.log 'markov_tweeter', e.message
    end
  end

  sleep_time = rand(120*60) # Two hours
  AnonRep::Helpers.log 'markov_tweeter', "Sleeping for #{sleep_time / 60} minutes prior to next tweet"
  sleep sleep_time
end
