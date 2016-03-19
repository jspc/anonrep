#!/usr/bin/env ruby

$LOAD_PATH << File.join(__FILE__, '..', 'lib')

require 'rsses'
require 'helpers'

require 'chatterbot/dsl'
require 'yaml'
require 'whatlanguage'

exclude 'game', 'book', 'author', 'business', 'crafts', 'http://', 'https://'
use_streaming

# On tweet, follow users bellow #{bottom_limit} and above #{upper_limit}
bottom_limit   = ENV.fetch('BOTTOM_LIMIT', 500)
upper_limit    = ENV.fetch('UPPER_LIMIT', 10000)

# FFFUUUCCCCKKKKKKK YYYOOOUUUU Future James
config_dir = ENV.fetch('DOCKER_MODE', 0).to_i == 1 ? '/config' : File.join(File.dirname(__FILE__), 'config')
config = YAML.load File.read( File.join(config_dir , 'config.yml') )

wl = WhatLanguage.new(:all)

search config['search_terms'] do |tweet|
  unless tweet.retweet? or tweet.reply? or wl.language(tweet.text) != :english
    user = tweet.user

    # Try and avoid spam bots
    if user.followers_count > 50 and (user.followers_count < bottom_limit or user.followers_count >= upper_limit)
      AnonRep::Helpers.follow_and_log 'search_watcher', user
    end

  end
end
