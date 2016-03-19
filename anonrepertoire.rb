#!/usr/bin/env ruby

$LOAD_PATH << File.join(__FILE__, '..', 'lib')

require 'rsses'
require 'helpers'

require 'chatterbot/dsl'
require 'colorize'
require 'yaml'
require 'whatlanguage'
require 'time'
require 'json'

#verbose
exclude 'game', 'book', 'author', 'business', 'crafts', 'http://', 'https://'
use_streaming

# On tweet, follow users bellow #{bottom_limit} and above #{upper_limit}
bottom_limit   = 500
upper_limit    = 10000
max_link_limit = client.configuration.short_url_length

config = YAML.load File.read('./config.yml')
tweets = JSON.load File.read('./tweets-curated.json')
wl = WhatLanguage.new(:all)

fork do
  search config['search_terms'] do |tweet|
    unless tweet.retweet? or
          tweet.reply? or
          wl.language(tweet.text) != :english

      user = tweet.user

      # Try and avoid spam bots
      if user.followers_count > 50 and (user.followers_count < bottom_limit or user.followers_count >= upper_limit)
        AnonRep::Helpers.follow_and_log 'search_watcher', user
      end

    end
  end
end

fork do
  followed do |user|
    AnonRep::Helpers.log "follow_backer", "Followed by #{user.screen_name}"
    AnonRep::Helpers.follow_and_log "follow_backer",  user
  end
end

fork do
  loop do
    t = tweets['tweets'].delete_at(rand(tweets['tweets'].length))
    tweet t

    AnonRep::Helpers.log 'markov_tweeter', "Tweeted '#{t}'"

    File.open('./tweets_unsent.json', 'w'){|f| f.puts tweets.to_json}

    sleep_time = rand(120*60) # Two hours
    AnonRep::Helpers.log 'markov_tweeter', "Sleeping for #{sleep_time / 60} minutes prior to next tweet"
    sleep sleep_time
  end
end

fork do
  loop do
    AnonRep::Helpers.log 'summariser', 'Starting summary spider'
    summaries = AnonRep::RSS.iterate config['feeds'], max_link_limit
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
end

Process.waitall
