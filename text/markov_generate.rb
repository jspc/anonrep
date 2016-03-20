#!/usr/bin/env ruby

require 'marky_markov'

module AnonRep
  module Markov

    def self.generate count=500
      workdir = File.join(File.dirname(__FILE__))
      markov = MarkyMarkov::Dictionary.new("#{workdir}/dictionary")

      unless File.file? "#{workdir}/dictionary.mmd"
        Dir.glob("#{workdir}/sources/*").each do |f|
          markov.parse_file f
        end
      end

      sentences = []
      until sentences.size == count do
        sentence = markov.generate_1_sentences
        sentences << sentence if sentence.size <= 140
      end

      markov.save_dictionary!
      sentences
    end

  end
end
