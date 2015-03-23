require 'net/http'
require 'json'
require 'data_mapper'

DataMapper::setup(:default, "sqlite3://#{Dir.pwd}/collection.db")

class Clip
  include DataMapper::Resource
  property :id, Serial
  property :owner, Text, :required => true
  property :yt_tag, Text, :required => true
  property :gfy_tag, Text, :required => true
end

class User
  include DataMapper::Resource
  property :id, Serial
  property :yt_name, Text, :required => true, :unique => true
  property :yt_id, Text, :required => true, :unique => true
  property :pass, Text, :required => true
  property :slug, Text, :required => true
  property :twitch_name, Text
  property :twitter_name, Text
end

DataMapper.finalize.auto_upgrade!

def get arg
  uri= URI(arg)
  Net::HTTP.get_response(uri)
end

def gfy video, channel
  v = video['contentDetails']['videoId']
  tmp = get "http://upload.gfycat.com/transcodeRelease?fetchUrl=https://www.youtube.com/watch?v=#{v}&fetchSeconds=10&fetchLength=10"
  c = Clip.new
  c.owner = channel
  c.yt_tag = v
  c.gfy_tag = JSON.parse(tmp.body)['gfyname']
  c.save
  p c
end

def yt_grab user, clips
  user.yt_id[1] = 'U'
  id = user.yt_id
  tmp = get "https://www.googleapis.com/youtube/v3/playlistItems?part=contentDetails,snippet,status&playlistId=#{id}&key=AIzaSyAz1-j_VYeDE_3rdlXfFul5EdIU1bC4jMQ&maxResults=25"
  vids = JSON.parse(tmp.body)['items'].select { |i|
    i['status']['privacyStatus'] == 'public' && (i['snippet']['title'].downcase.include?('#bb') || i['snippet']['description'].downcase.include?('#bb')) && clips.all? { |c|
    	i['contentDetails']['videoId'] != c.yt_tag
    }
  }
  vids.each { |v|
  	gfy v, user.yt_name
  }
  p "completed: #{clips.length} @ #{Time.now}"
end

def work
  users = User.all
  clips = Clip.all

  #setup new users
  users.each { |u|
    if u.yt_id.nil?
      u.yt_id = channel_id u.yt_name
      u.save
    end
    #update clips
    yt_grab u, clips
  }
end

if $0 == __FILE__
  # do stuff
  work
end