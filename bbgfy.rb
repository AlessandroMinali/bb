require 'sinatra'
require_relative 'v2g.rb'

helpers do
	def offline? channel
	  uri = URI('https://api.twitch.tv/kraken/streams/'+ channel)
	  JSON.parse(
	  	Net::HTTP.get_response(URI('https://api.twitch.tv/kraken/streams/'+ channel)).body
	  )["stream"].nil?
	end
end

before do
	@live = "none" if offline? 'silentbunny'
end

get '/' do
	@clips = Clip.all(:limit => 9).shuffle
	erb :index
end

get '/about' do
	erb :about
end

get '/submit' do
	erb :submit
end

not_found do
  redirect('/')
end

get '/video/:id' do
	@id = params[:id]
	erb :video
end

error do
  'Sorry there was a nasty error - ' + env['sinatra.error'].name
end

#clean up secrets
#make v2g  background task that can be spun up for a specific user
#filter yt by string in title
#make user sign up page | model
#display user pages
#simple email campaign

#play button || like button