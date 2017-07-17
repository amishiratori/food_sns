require 'bundler'
Bundler.require

require './app'


Cloudinary.config do |config|
  config.cloud_name = "dg61muele"
  config.api_key    = "712765872288194"
  config.api_secret = "XZ7jjADT4CZBKj6MbqpEzGC2X4c"
end

run Sinatra::Application
