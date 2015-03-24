require 'sinatra'
require 'json'
require 'securerandom'
require 'digest'
require 'erubis'
require 'rack-flash'
require_relative 'v2g.rb'

# enable :sessions
# use Rack::Flash, :sweep => true

#escape html
set :erb, :escape_html => true

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
	# def channel_exists? name
	#   tmp = get "https://www.googleapis.com/youtube/v3/search?part=snippet&channelType=any&q=#{name}&type=channel&key=#{$api}&maxResults=1"
	#   tmp = JSON.parse(tmp.body)
 #    begin
 #    	tmp['items'][0]['id']['channelId']
 #    rescue
 #    	halt "channel name not found try again<hr><a href=#{request.referer}>Back</a>"
 #    end
	# end

	def matches q
		tmp = get "https://www.googleapis.com/youtube/v3/search?part=snippet&channelType=any&q=#{q}&type=channel&key=#{$api}&maxResults=5"
		tmp = JSON.parse(tmp.body)
		chans = []
		tmp['items'].each { |i|
			chans << [i['id']['channelId'], i['snippet']['title'], i['snippet']['channelTitle']]
		}
		chans
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
	@id = params[:id]
	u = User.first(:yt_name => params[:id])
	if u.nil?
		# flash[:notice] = "user does not exist"
		# redirect request.referer
		halt "user does not exist<hr><a href='/'>Back</a>"
	end
	@clips = Clip.all(:owner => params[:id], :limit => 12).shuffle
	erb :index
end

#sign up dialog
get '/signup' do
	erb :signup
end

#allow user to select right yt channel
get '/signup/confirm' do
	@choose = matches params['user-name']
	halt "invalid youtube channel<hr><a href=#{request.referer}>Back</a>" if @choose.empty?
	erb :confirm
end

#verify signup details and reroute if mal formed
post '/signup' do
	halt "select a channel<hr><a href=#{request.referer}>Back</a>" if params['chan-info'].nil?
	tmp = params['chan-info'].split(',')
	email = params[:email]
	chan = tmp[1]
	id = tmp[0]

	halt "invalid email<hr><a href=#{request.referer}>Back</a>" if (/^\S+@\S+$/ =~ email).nil?
	halt "email already in use<hr><a href=#{request.referer}>Back</a>" unless (User.first(:email => email)).nil?
	halt "bloodborne.me account already exists<hr><a href='/u/#{chan}'>Go to page</a>" unless (User.first(:yt_name => chan)).nil?
	ha, se = hash_n_salt email

	chan = chan.gsub(/ /,'_')
	u = User.new
	u.yt_name = chan
	u.yt_id = id
	u.email = email
	u.pass = ha
	u.slug = se
	u.save
	p u
	redirect "/u/#{chan}"
end

#show embed yt player
get '/u/:id/video/:video' do
	@id = params[:id]
	@video = params[:video]
	halt "user does not own this video<hr><a href='/'>Back</a>" if (Clip.first(:owner => @id, :yt_tag => @video)).nil?
	erb :video
end

#about page
get '/about' do
	erb :about
end

delete '/clip/:id' do
	halt 401, 'not authorized' unless params[:key] == 'secret'
	c = Clip.first(:yt_tag => params[:id])
	c.destroy unless c.nil?

	status 200
end

delete '/user/:id' do
	halt 401, 'not authorized' unless params[:key] == 'secret'
	u = User.first(:yt_name => params[:id])
	u.destroy unless u.nil?

	c = Clip.all(:owner => params[:id])
	c.destroy unless c.nil?

	status 200
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