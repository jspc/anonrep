#!/usr/bin/env ruby

$LOAD_PATH << File.join(__FILE__, '..', 'lib')

require 'rsses'
require 'helpers'

require 'chatterbot/dsl'
require 'redis'

use_streaming

tweets = JSON.load File.read('./tweets-curated.json')


loop do
  t = tweets['tweets'].delete_at(rand(tweets['tweets'].length))
  tweet t

  AnonRep::Helpers.log 'markov_tweeter', "Tweeted '#{t}'"

  File.open('./tweets_unsent.json', 'w'){|f| f.puts tweets.to_json}

  sleep_time = rand(120*60) # Two hours
  AnonRep::Helpers.log 'markov_tweeter', "Sleeping for #{sleep_time / 60} minutes prior to next tweet"
  sleep sleep_time
end
