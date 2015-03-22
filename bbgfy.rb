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

get '/' do
	@live = "none" if offline? 'silentbunny'
	@clips = Clip.all(:limit => 9).shuffle
	erb :index
end

get '/about' do
	"More bloodborne content to come!<br><h1>Planned</h1><ul><li>signing up to have your clips displayed</li><li>personal pages</li><li>voting</li><li>sharing on twitter</li><li>builds</li><li>pvp tactics</li><li>fashion!</li></ul>
	<hr><a href='http://twitch.tv/silentbunny'>Suggestions welcome over at my stream :) <3</a><hr><a href='/'>Back</a>"
end

get '/submit' do
	'<link rel="stylesheet" href="//maxcdn.bootstrapcdn.com/font-awesome/4.3.0/css/font-awesome.min.css"> want to get a notification when I make this an option? email me :)<a title="Gmail" href="mailto:alessandro.minali@mail.com">
			<i class="fa fa-envelope fa-lg"></i></a><hr><a href="/">Back</a>'
end
