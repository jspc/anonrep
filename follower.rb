#!/usr/bin/env ruby

$LOAD_PATH << File.join(__FILE__, '..', 'lib')

require 'helpers'
require 'chatterbot/dsl'

followed do |user|
  AnonRep::Helpers.log "follow_backer", "Followed by #{user.screen_name}"
  AnonRep::Helpers.follow_and_log "follow_backer",  user
end
