#!/usr/bin/env ruby

$LOAD_PATH << File.join(File.dirname(__FILE__), '..', 'lib')
$LOAD_PATH << File.join(File.dirname(__FILE__))

require 'redis'
require 'sinatra'
require 'markov_generate'

class AnonRepWeb < Sinatra::Application
  configure do
   use Rack::Session::Pool
    set :session_secret, 'some_placeholder'
  end

  get '/' do
    session[:tweets] = AnonRep::Markov.generate(50)
    @tweets = session[:tweets]

    erb :index
  end

  post '/' do
    redis_host = ENV.fetch('REDIS_HOST', 'localhost')
    redis_port = ENV.fetch('REDIS_PORT', 6379)

    redis_object = Redis.new(host: redis_host, port: redis_port)
    set_name = 'markov_tweets'

    params[:tweet].each do |tweets_index|
      redis_object.sadd set_name, session[:tweets][tweets_index.to_i]
    end
    redirect '/'
  end
end
