require 'colorize'
require 'time'

module AnonRep
  module Helpers

    def self.log process, msg
      puts "#{Time.now.utc.iso8601.green} : #{process.cyan} : #{msg.magenta}"
    end

    def self.follow_and_log process, user
      unless user.following?
        follow user
        log process, "Following #{user.screen_name}, #{user.followers_count} followers"
      end
    end
  end
end
