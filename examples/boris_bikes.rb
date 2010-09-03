# This library creates a FT and posts data from the Boris Bikes API to it every minute
#
# Add photos to infowindow
# Add fusion table graphs to the inside of the infowindows too


require 'net/http'
require 'uri'
require 'rubygems'
require 'geo_ruby'
require 'fusion_tables'
require 'time'
require 'json'
require 'ap'
include GeoRuby
include SimpleFeatures

class Object
  def try(method, *args, &block)
    send(method, *args, &block)
  end
end

def color max, number_to_color, min=0, opacity=80
  color = ["FFFFB2", "FFFFB2", "FEB24C", "FD8D3C", "F03B20", "BD0026"]
  #color = %w(FEE0D2 FCBBA1 FC9272 FB6A4A EF3B2C CB181D A50F15 67000D)
  color.reverse!
  #color = ["FFFFCC", "D9F0A3", "ADDD8E", "78C679", "31A354", "31A354"] #<- greens
  chunk = (max-min)/color.size
  index = (number_to_color/chunk).floor
  "#{color[index]}#{opacity}"
end

def to_google(x,y)
  a = `echo "#{x} #{y}" | cs2cs + +init=epsg:4326 +to +init=epsg:900913 -f "%.12f"`
  a = a.split(" ")
  {:x => a[0], :y => a[1]}
end

def from_google(x,y)
  a = `echo "#{x} #{y}" | cs2cs + +init=epsg:900913 +to +init=epsg:4326 -f "%.12f"`
  a = a.split(" ")
  {:x => a[0], :y => a[1]}
end


def buffer(center_x, center_y, radius, quality = 4, precision = 12)
  points = []
  radians = Math::PI / 180
  
  coords = to_google(center_x, center_y)
  center_x = coords[:x].to_f
  center_y = coords[:y].to_f
  
  0.step(360, quality) do |i|
    x = center_x + (radius * Math.cos(i * radians))
    y = center_y + (radius * Math.sin(i * radians))
    coords = from_google(x,y)
    points << Point.from_x_y(round(coords[:x].to_f, precision), round(coords[:y].to_f, precision))
  end
  points
end


def round number, precision = 12
  (number * 10**precision).round.to_f / 10**precision
end  

# Configure settings
config = YAML::load_file(File.join(File.dirname(__FILE__), 'credentials.yml'))
DEFAULT_SRID = 4328


# Configure fusion tables
ft = GData::Client::FusionTables.new
ft.clientlogin(config["google_username"], config["google_password"])
table_name = "Boris Bikes"
cols = [
  {:name => 'name',         :type => 'string'},  
  {:name => 'created_at',   :type => 'datetime'},
  {:name => 'updated_at',   :type => 'datetime'},
  {:name => 'boris_id',     :type => 'number'},
  {:name => 'temporary',    :type => 'number'},
  {:name => 'installed',    :type => 'number'},
  {:name => 'locked',       :type => 'number'},
  {:name => 'nb_empty_docs',:type => 'number'},
  {:name => 'nb_bikes',     :type => 'number'},
  {:name => 'nb_docs',      :type => 'number'},
  {:name => 'image',        :type => 'string'},
  {:name => 'geom',         :type => 'location'},  
  {:name => 'geom_fill',    :type => 'string'},  
  {:name => 'geom_border',  :type => 'string'},  
]

# Create FT if it doesn't exist
tables = ft.show_tables
table  = tables.select{|t| t.name == table_name}.first
table  = ft.create_table(table_name, cols) if !table

while true do
  bikes = JSON.parse(Net::HTTP.get(URI.parse('http://borisapi.heroku.com/stations.json')))  
  
  # get largest bike rack to calibrate buffer
  max = 0
  bikes.each do |b|
    slots = b["nb_empty_docks"] + b["nb_bikes"]
    max = slots if slots > max
  end  
  
  # loop through data constructing fusion table date
  data = []
  max_radius = 150.0 #in meters
  buffer_chunk = max_radius / max
  
  bikes.each do |b|
    if b["lat"].to_f > 50 #ignore non geographic ones
      docs = (b["nb_bikes"] + b["nb_empty_docks"])    
      geom = Polygon.from_points [buffer(b["long"].to_f, b["lat"].to_f, docs*buffer_chunk)]    
      #geom = Point.from_x_y b["long"].to_f, b["lat"].to_f
      
      data << {
        "name"          => b["name"],
        "created_at"    => Time::parse(b["created_at"]),
        "updated_at"    => Time::parse(b["updated_at"]),
        "boris_id"      => b["id"],
        "temporary"     => (b["temporary"] ? 1 : 0), 
        "installed"     => (b["installed"] ? 1 : 0),
        "locked"        => (b["locked"]    ? 1 : 0),
        "nb_empty_docs" => b["nb_empty_docks"],
        "nb_bikes"      => b["nb_bikes"],
        "nb_docs"       => docs,
        "image"         => "",
        "geom"          => geom.as_kml,
        "geom_fill"     => color(max,b["nb_bikes"]),
        "geom_border"   => color(max,b["nb_bikes"],0,"FF"),
      }
      puts "packing data for #{b["name"]}"
    end  
  end       
  
  # get current number of rows ready to delete
  row_ids = table.select "ROWID"
  
  # put new data up
  puts "sending bikes to fusion tables..."
  table.insert data
  
  # remove old data
  puts "deleting old rows"
  row_ids.each do |id|
    table.delete id[:rowid]
  end
    
  # Be nice and wait
  puts "...done! sleeping..."
  sleep 500
end

