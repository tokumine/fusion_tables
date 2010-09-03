# encoding: UTF-8
#
# Twitter Fusion Tables Mashup
# S.Tokumine 2010
#
# looks for tweets in the live stream around certain 
# cities and posts them to fusion tables with KML attached
#
# Gem dependencies:
#
# tweetstream
# GeoRuby
# fusion_tables
#
# Output from running this for an evening
# http://tables.googlelabs.com/DataSource?snapid=72509
#
require 'rubygems'
require 'tweetstream'
require 'geo_ruby'
include GeoRuby
include SimpleFeatures
require 'fusion_tables'
require 'time'
require 'yaml'

class Object
  def try(method, *args, &block)
    send(method, *args, &block)
  end
end

# Configure settings
config = YAML::load_file(File.join(File.dirname(__FILE__), 'credentials.yml'))
DEFAULT_SRID = 4328

# Twitter places
places = {
  :san_francisco => [-122.75,36.8,-121.75,37.8],
  :new_york      => [-74,40,-73,41],
  :tokyo         => [139.3,35,140.3,36],
  :london        => [-0.54,51.2,0.46,52.2],
  :madrid        => [-4.2,40,-3.2,41],
  :paris         => [1.75,48.5,2.75, 49.5],
  :beijing       => [115.9,39,116.9,40],
  :mumbai        => [72.75,18.88,73.75,19.88],
}

# Configure fusion tables
ft = GData::Client::FusionTables.new
ft.clientlogin(config["google_username"], config["google_password"])
table_name = "TwitterFusion"
cols = [
  {:name => 'screen_name',  :type => 'string'},  
  {:name => 'avatar',       :type => 'string'},
  {:name => 'text',         :type => 'string'},
  {:name => 'created',      :type => 'datetime'},
  {:name => 'url',          :type => 'string'},
  {:name => 'location',     :type => 'location'},
  {:name => 'iso',          :type => 'location'},
  {:name => 'country_name', :type => 'location'},  
  {:name => 'city',         :type => 'string'}
]

# Create FT if it doesn't exist
tables = ft.show_tables
table  = tables.select{|t| t.name == table_name}.first
table  = ft.create_table(table_name, cols) if !table

# Configure Twitter stream client
data = []
tw = TweetStream::Client.new(config["twitter_username"],config["twitter_password"])

# configure friendly rate limit handling
tw.on_limit do |skip_count|
  sleep 5
end 

# start searching twitter stream and posting to FT
tw.filter(:locations => places.values.join(",")) do |tweet|  
  begin    

    country = "unknown"
    iso     = "unknown"    
    begin
      country = tweet.try(:[],:place).try(:[], :country)
      iso = tweet.try(:[],:place).try(:[], :country_code)
    rescue
    end
        
    # Divine the tweets geometry
    #
    # overly complex due to 
    # * some US tweets have their lat/longs flipped (but not all...)
    # * some geo tweets are made using a "place" envelope rather than exact lat/kng      
    if tweet[:geo]
      if iso == 'US' && tweet[:geo][:coordinates][1] > 0
        p = Point.from_x_y(tweet[:geo][:coordinates][0],tweet[:geo][:coordinates][1]) 
      else
        p = Point.from_x_y(tweet[:geo][:coordinates][1],tweet[:geo][:coordinates][0]) 
      end  
    else
      p = Polygon.from_coordinates(tweet[:place][:bounding_box][:coordinates]).envelope.center
    end
  
    # work out which city the tweet is from by testing with an extended bounding box
    # BBox extention needed as twitter returns things outside our defined bboxes...
    city = "unknown"
    places.each do |key, value|
      if !(p.x < value[0]-1 || p.x > value[2]+1 || p.y < value[1]-1 || p.y > value[3]+1)         
        city = key.to_s.gsub("_"," ")    
        break
      end
    end
            
    # pack data    
    data << {
      "screen_name"  => tweet[:user][:screen_name],
      "avatar"       => tweet[:user][:profile_image_url],
      "text"         => tweet[:text],
      "created"      => Time.parse(tweet[:created_at]),
      "url"          => "http://twitter.com/#{tweet[:user][:screen_name]}/status/#{tweet[:id]}",
      "location"     => p.as_kml,
      "iso"          => iso,
      "country_name" => country,
      "city"         => city
    } 
  rescue => e
    puts "ERROR: #{e.inspect}, #{e.backtrace}"
    #let sleeping dogs lie...
  end  
  
  # let us know how we're doing
  puts "#{50-data.size}: #{city}, #{tweet.text}"
  
  # Post to fusion tables  
  if data.size == 50
    puts "sending data to fusion tables..."
    ft_data = data
    data = []
    table.insert ft_data
  end      
end