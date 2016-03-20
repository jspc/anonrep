module AnonRep
  module Tweets

    def self.return_and_remove redis_object
      set_name = 'markov_tweets'

      t = redis_object.srandmember(set_name).force_encoding('UTF-8')
      redis_object.srem set_name, t
      return t
    end

  end
end
