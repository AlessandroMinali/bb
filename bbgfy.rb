require 'sinatra'
require 'json'
require 'securerandom'
require 'digest'
require_relative 'v2g.rb'

helpers do
	# def offline? channel
	#   uri = URI('https://api.twitch.tv/kraken/streams/' + channel)
	#   JSON.parse(
	#   	Net::HTTP.get_response(URI('https://api.twitch.tv/kraken/streams/' + channel)).body
	#   )["stream"].nil?
	# end

	#sha512 pass and append random salt
	def hash_n_salt pass
		s = SecureRandom.hex
		return [Digest::hexencode(Digest::SHA512.new.digest(pass + s)), s]
	end

	#grab first search results on channel name ##TODO make a better method of verfiying accounts
	def channel_exists? name
	  tmp = get "https://www.googleapis.com/youtube/v3/search?part=snippet&channelType=any&q=#{name}&type=channel&key=AIzaSyAz1-j_VYeDE_3rdlXfFul5EdIU1bC4jMQ&maxResults=1"
	  tmp = JSON.parse(tmp.body)
    tmp['items'][0]['id']['channelId']
	end
end

# before do
# 	@live = "none" if offline? 'silentbunny'
# end

#show first block of clips randomly
get '/' do
	@clips = Clip.all(:limit => 12*3).shuffle
	erb :index
end

get '/u' do
	@users = User.all
	erb :users
end

#display user page
get '/u/:id' do
	u = User.first(:yt_name => params[:id])
	halt "user does not exist<hr><a href='/'>Back</a>" if u.nil?
	@clips = Clip.all(:owner => params[:id], :limit => 12).shuffle
	erb :index
end

#sign up dialog
get '/signup' do
	erb :signup
end

#verify signup details and reroute if mal formed
post '/signup' do
	chan, pass = params['user-name'], params[:password]
	b = ''
	if pass.length < 6
		b = "password too short, minimum of 6 characters"
	end
	if chan.empty?
		b = "channel name needs to be given<br>" + b
	end
	halt b + "<hr><a href=#{request.referer}>Back</a>" unless b.empty?
	id = channel_exists?(chan)

	ha, se = hash_n_salt pass
	u = User.new
	u.yt_name = chan
	u.yt_id = id
	u.pass = ha
	u.slug = se
	u.save
	p u
	redirect "/u/#{chan}"
end

#show embed yt player
get '/u/:owner/video/:id' do
	@id = params[:id]
	@owner = params[:owner]
	erb :video
end

#about page
get '/about' do
	erb :about
end

#no idea?
# get '/news' do
# 	erb :submit
# end

not_found do
  redirect('/')
end

error do
  'Sorry there was a nasty error - ' + env['sinatra.error'].name
end