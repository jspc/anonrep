require 'json'
require 'open-uri'
require 'ots'
require 'simple-rss'
require 'whatlanguage'

module AnonRep
  module RSS

    def self.iterate feeds, max_link_length
      wl = WhatLanguage.new(:all)

      summaries = []
      feeds.each do |feed|
        rss = SimpleRSS.parse open(feed)
        rss.entries.each do |entry|
          link = entry.link
          break unless untweeted_link? feed, link

          content = extract_content(entry)
          break unless content

          normalised_content = content.force_encoding('UTF-8').gsub(/<[^>]*>/, '')
          summariser = OTS.parse(normalised_content)
          summary = summariser.summarize(sentences: 1).first[:sentence].strip

          # Ensure short enough to post: twitter will truncate link to max_link_length and we split with a space
          if summary.size < (140 - 1 - max_link_length) and wl.language(summary) == :english
            summaries << "#{summary} #{link}"
          end
        end
      end
      summaries
    end

    def self.untweeted_link? feed, url
      urls_path = 'urls.json'

      urls = File.file?(urls_path) ? JSON.parse(File.read(urls_path)) : {}

      unless urls[feed]
        urls[feed] = []
      end

      if urls[feed].include? url
        return false
      end

      urls[feed] << url
      File.open(urls_path, 'w'){|f| f.puts urls.to_json}
      true
    end

    def self.extract_content entry
      if entry.key?(:content_encoded)
        return entry[:content_encoded]
      elsif entry.key?(:content)
        return entry[:content]
      elsif entry.key?(:description)
        return entry[:description]
      end

      return false
    end

  end
end
