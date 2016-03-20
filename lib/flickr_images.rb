require 'flickraw'
require 'tempfile'
require 'httparty'

module AnonRep
  module Flickr

    def self.image_search search_term
      FlickRaw.api_key = ENV.fetch('FLICKR_KEY','')
      FlickRaw.shared_secret = ENV.fetch('FLICKR_SECRET', '')

      args = {
        license: '7,8,9,10',
        per_page: 20,
        sort: 'relevance',
        text: search_term,
      }
      flickr.photos.search(args).map{|p| FlickRaw.url p}
    end

    def self.store uri
      file = Tempfile.new('flickr')
      file.binmode
      file.write( HTTParty.get(uri).parsed_response )
      file.close
      file.open
      return file
    end
  end
end
