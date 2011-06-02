fusion-tables
==============

This gem lets you easily interact with [Google Fusion Tables](http://www.google.com/fusiontables/Home) from your Ruby application. Read more in this [Blog post](http://www.tokumine.com/2010/08/10/fusion-tables-gem/).

Demo and examples
------------------

* Twitter [demo](http://tables.googlelabs.com/DataSource?snapid=73106) / [code](http://github.com/tokumine/fusion-tables/blob/master/examples/compare_tweets.rb)
* Boris bike [demo](http://tables.googlelabs.com/DataSource?snapid=78314) / [code](http://github.com/tokumine/fusion-tables/blob/master/examples/boris_bikes.rb) 
* [Tests](http://github.com/tokumine/fusion-tables/tree/master/test/)

Installation
-------------

``` bash
gem install fusion_tables
```

**Gem Dependencies**

* gdata_19 >= 1.1.2

**Rubies**

* 1.8.7
* 1.9.2-p180

Usage 
------
``` ruby
require 'fusion_tables'
	
# Connect to service	
@ft = GData::Client::FusionTables.new      
@ft.clientlogin(username, password)

# Browse existing tables
@ft.show_tables
 # => [table_1, table_2] 

# Getting table id suitable for using with google maps (see more below)
table_1.id #=> 42342 (the table's google id)

# Count data
table_1.count #=> 1

# Select data
table_1.select 
 #=> data

# Select data with conditions
table_1.select "name", "WHERE x=n"
 #=> data

# Select ROWIDs
row_ids = table_1.select "ROWID"

# Drop tables
@ft.drop table_1.id                    # table id
@ft.drop [table_1.id, table_2.id]     # arrays of table ids
@ft.drop /yacht/                      # regex on table name

# Creating a table
cols = [{:name => "friend name",    :type => 'string' },
        {:name => "age",            :type => 'number' },
        {:name => "meeting time",   :type => 'datetime' },
        {:name => "where",          :type => 'location' }]

new_table = @ft.create_table "My upcoming meetings", cols

# Inserting rows (auto chunks every 500)
data = [{"friend name" 	=> "Eric Wimp", 
         "age"          => 25, 
         "meeting time" => Time.utc(2010,"aug",10,20,15,1),
         "where"        => "29 Acacia Road, Nuttytown"}]
new_table.insert data

# Delete row
new_table.delete row_id
```

Currently only single row UPDATE query is implemented.

``` ruby
row_id = 1
data = [{"friend name" 	=> "Eric Wimp", 
         "age"          => 25, 
         "meeting time" => Time.utc(2010,"aug",10,20,15,1),
         "where"        => "29 Acacia Road, Nuttytown"}]
new_table.update row_id, data	
```

Known Issues
-------------

* The Google gdata_19 gem conflicts with the GData2 gem. Only current fix is to uninstall GData2.
* You have to make a table public before you can display it on a map. This can only be done via FT web interface. 

Note on Patches/Pull Requests
------------------------------
 
* Fork the project.
* Make your feature addition or bug fix.
* Add tests for it. This is important so I don't break it in a
  future version unintentionally.
* Commit, do not mess with rakefile, version, or history.
  (if you want to have your own version, that is fine but bump version in a commit by itself I can ignore when I pull)
* Send me a pull request. Bonus points for topic branches.

History
--------

Largely based on Tom Verbeure's [work for MTBGuru](http://code.google.com/p/mtbguru-fusiontables/)

Contributors
-------------

* tokumine
* sikachu
* troy
* wynst

