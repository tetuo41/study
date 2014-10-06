#!/usr/bin/ruby -Ku

# http://atnd.org/
# https://api.atnd.org/
# http://www.doorkeeper.jp/
# http://www.doorkeeperhq.com/developer/api
# http://www.zusaar.com/
# http://www.zusaar.com/doc/api.html
# http://connpass.com/
# http://connpass.com/about/api/

module ApiCommonModule 
  require 'rubygems'
  require 'net/http'
  require 'uri'
  require 'json'
  require 'date'
  # json
  def read_json
  json = Net::HTTP.get(URI.parse(@api_url))
  return JSON.parse(json)
  end
  # Make args to string
  def makeArg(args)
    arg_array = []
    args.each do |arg|
      arg_array << arg.to_a.join("=") if arg.values != [nil]
    end
    return  "?#{arg_array.join("&")}"
  end
end

# ==========================================
class EventATND
  attr_accessor :event_id, :title, :catch, :description
  attr_accessor :event_url, :started_at, :ended_at
  attr_accessor :url, :limit, :address, :place, :lat
  attr_accessor :lon, :owner_id, :owner_nickname
  attr_accessor :owner_twitter_id, :accepted, :waiting, :updated_at
end

class EventZusaar
  attr_accessor :event_id, :title, :catch
  attr_accessor :description, :event_url, :started_at, :ended_at
  attr_accessor :pay_type, :url, :limit, :address
  attr_accessor :place, :lat, :lon, :owner_id, :owner_profile_url, :owner_nickname
  attr_accessor :accepted, :waiting, :updated_at
end

class EventConnpass
  attr_accessor :event_id, :title, :catch
  attr_accessor :description, :event_url, :hash_tag, :started_at, :ended_at
  attr_accessor :limit, :event_type, :series, :id
  attr_accessor :title, :url, :address, :place
  attr_accessor :lat, :lon, :owner_id, :owner_nickname
  attr_accessor :owner_display_name, :accepted, :waiting, :updated_at
end

class EventDoorkeeper
  attr_accessor :title, :id, :starts_at, :ends_at, :venue_name
  attr_accessor :address, :lat, :long, :ticket_limit
  attr_accessor :published_at, :updated_at
  attr_accessor :banner, :description, :public_url, :participants
  attr_accessor :waitlisted, :group
end

ATNDS_API_URL      = 'http://api.atnd.org/events/'
ZUSAAR_API_URL     = 'http://www.zusaar.com/api/event/'
CONNPASS_API_URL   = 'http://connpass.com/api/v1/event/'
DOORKEEPER_API_URL = 'http://api.doorkeeper.jp/'

# ==========================================
class ATNDS
  include ApiCommonModule
  attr_accessor :api_url,:events

  def initialize(arg={})
    arg[:ym]     = Time.now.strftime("%Y%m") if arg.fetch(:ym,nil) == nil
    arg[:format] = "json" if arg.fetch(:format,nil) == nil
    arg[:count]  = 100 if arg.fetch(:count,nil) == nil
    arg[:start]  = 0
    @arg         = arg
    @events      = []

    loop do 
      self.make_url
      break if self.read_json["events"].size == 0
      set_event_data(self.read_json)
      arg[:start] = arg[:start] + 100
    end
  end

  # URL作成
  def make_url
    @api_url = ATNDS_API_URL
    args     = []
    args << {:event_id   => @arg.fetch(:event_id,nil)}
    args << {:keyword    => @arg.fetch(:keyword,nil)}
    args << {:keyword_or => @arg.fetch(:keyword_or,nil)}
    args << {:ym         => @arg.fetch(:ym,nil)}
    args << {:ymd        => @arg.fetch(:ymd,nil)}
    args << {:user_id    => @arg.fetch(:user_id,nil)}
    args << {:nickname   => @arg.fetch(:nickname,nil)}
    args << {:twitter_id => @arg.fetch(:twitter_id,nil)}
    args << {:owner_id   => @arg.fetch(:owner_id,nil)}
    args << {:owner_nickname   => @arg.fetch(:owner_nickname,nil)}
    args << {:owner_twitter_id => @arg.fetch(:owner_twitter_id,nil)}
    args << {:start      => @arg.fetch(:start,nil)}
    args << {:count      => @arg.fetch(:count,nil)}
    args << {:format     => @arg.fetch(:format,nil)}
    @api_url = @api_url + self.makeArg(args)
  end

  def set_event_data(eventData)
    eventData["events"].each do |event|
      event = event["event"]
      eve   = EventATND.new
      eve.event_id         = event["event_id"]
      eve.title            = event["title"]
      eve.catch            = event["catch"]
      eve.description      = event["description"]
      eve.event_url        = event["event_url"]
      eve.started_at       = event["started_at"]
      eve.ended_at         = event["ended_at"]
      eve.url              = event["url"]
      eve.limit            = event["limit"]
      eve.address          = event["address"]
      eve.place            = event["place"]
      eve.lat              = event["lat"]
      eve.lon              = event["lon"]
      eve.owner_id         = event["owner_id"]
      eve.owner_nickname   = event["owner_nickname"]
      eve.owner_twitter_id = event["owner_twitter_id"]
      eve.accepted         = event["accepted"]
      eve.waiting          = event["waiting"]
      eve.updated_at       = event["updated_at"]
      @events << eve
    end
  end
end

# ==========================================

class Zusaar
  include ApiCommonModule
  attr_accessor :api_url,:events

  def initialize(arg={})
    arg[:ym]     = Time.now.strftime("%Y%m") if arg.fetch(:ym,nil) == nil
    arg[:count]  = 100 if arg.fetch(:count,nil) == nil

    arg[:start]  = 0
    @arg         = arg
    @events      = []

    loop do 
      self.make_url
      break if self.read_json["event"].size == 0
      set_event_data(self.read_json)
      arg[:start] = arg[:start] + 100
    end
  end

  # URL作成
  def make_url
    @api_url = ZUSAAR_API_URL
    args     = []
    args << {:event_id   => @arg.fetch(:event_id,nil)}
    args << {:keyword    => @arg.fetch(:keyword,nil)}
    args << {:keyword_or => @arg.fetch(:keyword_or,nil)}
    args << {:ym         => @arg.fetch(:ym,nil)}
    args << {:ymd        => @arg.fetch(:ymd,nil)}
    args << {:user_id    => @arg.fetch(:user_id,nil)}
    args << {:nickname   => @arg.fetch(:nickname,nil)}
    args << {:owner_id   => @arg.fetch(:owner_id,nil)}
    args << {:owner_nickname => @arg.fetch(:owner_nickname,nil)}
    args << {:start      => @arg.fetch(:start,nil)}
    args << {:count      => @arg.fetch(:count,nil)}
    args << {:format     => @arg.fetch(:format,nil)}
    @api_url = @api_url + self.makeArg(args)
  end

  def set_event_data(eventData)
    # p eventData["results_returned"]
    # p eventData["results_start"]
    eventData["event"].each do |event|
      eve = EventZusaar.new
      eve.event_id          = event["event_id"]
      eve.title             = event["title"]
      eve.catch             = event["catch"]
      eve.description       = event["description"]
      eve.event_url         = event["event_url"]
      eve.started_at        = event["started_at"]
      eve.ended_at          = event["ended_at"]
      eve.pay_type          = event["pay_type"]
      eve.url               = event["url"]
      eve.limit             = event["limit"]
      eve.address           = event["address"]
      eve.place             = event["place"]
      eve.lat               = event["lat"]
      eve.lon               = event["lon"]
      eve.owner_id          = event["owner_id"]
      eve.owner_profile_url = event["owner_profile_url"]
      eve.owner_nickname    = event["owner_nickname"]
      eve.accepted          = event["accepted"]
      eve.waiting           = event["waiting"]
      eve.updated_at        = event["updated_at"]
      @events << eve
    end
  end
end
# ==========================================
class Connpass
  include ApiCommonModule
  attr_accessor :api_url,:events

  def initialize(arg={})
    @api_url     = CONNPASS_API_URL
    arg[:ym]     = Time.now.strftime("%Y%m") if arg.fetch(:ym,nil) == nil
    arg[:count]  = 100 if arg.fetch(:count,nil) == nil
    arg[:format] = "json" if arg.fetch(:format,nil) == nil
    arg[:start]  = 0
    @arg         = arg
    @events      = []
  

    loop do 
      self.make_url
      break if self.read_json["events"].size == 0
      set_event_data(self.read_json)
      arg[:start] = arg[:start] + 100
    end
  end

  # URL作成
  def make_url
    args = []
    args << {:event_id   => @arg.fetch(:event_id,nil)}
    args << {:keyword    => @arg.fetch(:keyword,nil)}
    args << {:keyword_or => @arg.fetch(:keyword_or,nil)}
    args << {:ym         => @arg.fetch(:ym,nil)}
    args << {:ymd        => @arg.fetch(:ymd,nil)}
    args << {:nickname   => @arg.fetch(:nickname,nil)}
    args << {:owner_nickname   => @arg.fetch(:owner_nickname,nil)}
    args << {:start      => @arg.fetch(:start,nil)}
    args << {:order      => @arg.fetch(:order,nil)}
    args << {:series_id  => @arg.fetch(:series_id,nil)}
    args << {:count      => @arg.fetch(:count,nil)}
    args << {:format     => @arg.fetch(:format,nil)}
    @api_url = @api_url + self.makeArg(args)  
  end

  def set_event_data(eventData)
    # p eventData["results_returned"]
    # p eventData["results_available"]
    # p eventData["results_start"]
    eventData["events"].each do |event|
      eve = EventConnpass.new
      eve.event_id           = event["event_id"]
      eve.title              = event["title"]
      eve.catch              = event["catch"]
      eve.description        = event["description"]
      eve.event_url          = event["event_url"]
      eve.hash_tag           = event["hash_tag"]
      eve.started_at         = event["started_at"]
      eve.ended_at           = event["ended_at"]
      eve.limit              = event["limit"]
      eve.event_type         = event["event_type"]
      eve.address            = event["address"]
      eve.place              = event["place"]
      eve.lat                = event["lat"]
      eve.lon                = event["lon"]
      eve.owner_id           = event["owner_id"]
      eve.owner_nickname     = event["owner_nickname"]
      eve.owner_display_name = event["owner_display_name"]
      eve.accepted           = event["accepted"]
      eve.waiting            = event["waiting"]
      eve.updated_at         = event["updated_at"]
      @events << eve
    end
  end
end


class Doorkeeper
  include ApiCommonModule
  attr_accessor :api_url,:events

  def initialize(arg={})
    this_y,this_m = 0 
    if arg.fetch(:ym,nil) == nil
      this_y = Time.now.strftime("%Y").to_i
      this_m = Time.now.strftime("%m").to_i
    else
      this_y = arg[:ym][0..3].to_i
      this_m = arg[:ym][4,2].to_i
    end
    arg[:since]  = "#{this_y}#{this_m}#{Time.now.strftime("%d")}"
    arg[:until]  = Date.new(this_y, this_m, -1)
    arg[:page]   = 0
    @arg         = arg
    @events      = []
    
    loop do
      self.make_url
      break if (self.read_json).size == 0
      self.set_event_data(self.read_json)
      arg[:page] = arg[:page] + 1
    end
  end

  # URL作成
  def make_url
    @api_url = DOORKEEPER_API_URL
    @api_url = @api_url + 'events'
      args     = []
    args << {:page     => @arg.fetch(:page,nil)}
    args << {:locale   => @arg.fetch(:locale,nil)}
    args << {:sort     => @arg.fetch(:sort,nil)}
    args << {:since    => @arg.fetch(:since,nil)}
    args << {:until    => @arg.fetch(:until,nil)}
    args << {:callback => @arg.fetch(:callback,nil)}
    @api_url = @api_url + self.makeArg(args)
  end

  def set_event_data(eventData)
    eventData.each do |event|
      eve = EventDoorkeeper.new
      eve.title        = event["event"]["title"]
      eve.id           = event["event"]["id"]
      eve.starts_at    = event["event"]["starts_at"]
      eve.ends_at      = event["event"]["ends_at"]
      eve.venue_name   = event["event"]["venue_name"]
      eve.address      = event["event"]["address"]
      eve.lat          = event["event"]["lat"]
      eve.long         = event["event"]["long"]
      eve.ticket_limit = event["event"]["ticket_limit"]
      eve.published_at = event["event"]["published_at"]
      eve.updated_at   = event["event"]["updated_at"]
      eve.banner       = event["event"]["banner"]
      eve.description  = event["event"]["description"]
      eve.public_url   = event["event"]["public_url"]
      eve.participants = event["event"]["participants"]
      eve.waitlisted   = event["event"]["waitlisted"]
      @events << eve
    end
  end
end

# ==========================================
options = {:ym => "201410"}
result = ATNDS.new(options)
result.events.each { |data| p "#{data.started_at} : #{data.title} : #{data.event_url}" }
result = Zusaar.new(options)
result.events.each { |data| p "#{data.started_at} : #{data.title} : #{data.event_url}" }
result = Connpass.new(options)
result.events.each { |data| p "#{data.started_at} : #{data.title} : #{data.event_url}" }
result = Doorkeeper.new(options)
result.events.each { |data| p "#{data.starts_at} : #{data.title} : #{data.public_url}" }

