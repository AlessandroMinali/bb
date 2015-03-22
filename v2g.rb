require 'net/http'
require 'json'
require 'data_mapper'

DataMapper::setup(:default, "sqlite3://#{Dir.pwd}/collection.db")

class Clip
  include DataMapper::Resource
  property :id, Serial
  property :yt_tag, Text, :required => true
  property :gfy_tag, Text, :required => true
end

DataMapper.finalize.auto_upgrade!

def get arg
  uri= URI(arg)
  Net::HTTP.get_response(uri)
end

def gfy arg
  v = arg['contentDetails']['videoId']
  tmp = get "http://upload.gfycat.com/transcodeRelease?fetchUrl=https://www.youtube.com/watch?v=#{v}&fetchSeconds=10&fetchLength=10"

  c = Clip.new
  c.yt_tag = v
  c.gfy_tag = JSON.parse(tmp.body)['gfyname']
  c.save
  p c
end

def yt_grab
  clips = Clip.all
  tmp = get "https://www.googleapis.com/youtube/v3/playlistItems?part=contentDetails,status&playlistId=UUoHfcleicsCs3yLqjjjjqfw&key=AIzaSyAz1-j_VYeDE_3rdlXfFul5EdIU1bC4jMQ&maxResults=25"
  vids = JSON.parse(tmp.body)['items'].select { |i|
    i['status']['privacyStatus'] == 'public' && clips.all? { |c|
    	i['contentDetails']['videoId'] != c.yt_tag
    }
  }

  vids.each { |v|
  	gfy v
  }
end
