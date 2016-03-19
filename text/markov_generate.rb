#!/usr/bin/env ruby

require 'marky_markov'

markov = MarkyMarkov::Dictionary.new('dictionary')

unless File.file? 'dictionary.mmd'
  Dir.glob('text/*').each do |f|
    markov.parse_file f
  end
end

500.times do
  puts markov.generate_1_sentences
end

markov.save_dictionary!
