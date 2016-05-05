# Sequel::Audited

**sequel-audited** is a [Sequel](http://sequel.jeremyevans.net/) plugin that logs changes made to any 
audited model, including who created, updated and destroyed the record, and what was changed 
and when the change was made. 

This plugin provides model auditing (a.k.a: record versioning) for DB scenarios when DB triggers 
are not possible. (ie: on a web app on Heroku).



## Disclaimer

This is still **work-in-progress**, and is therefore **NOT production ready**, so **use with care** 
and test thoroughly before depending upon this gem for mission-critical stuff! 
You have been warned! No warranties and guarantees expressed or implied!

<br>

Having said that, the code base has 100% code coverage and I believe all significant tests pass.

----

<br>

## Installation

### 1) Install the gem 

Add this line to your app's Gemfile:


```ruby
gem 'sequel-audited'
```

And then execute:

```bash
$ bundle
```

Or install it yourself as:

```bash
$ gem install sequel-audited
```


### 2)  Generate Migration

In your apps Rakefile add the following:

```ruby
load 'tasks/sequel-audited/migrate.rake'
```

Then verify that the Rake task is available by calling:

```bash
bundle exec rake -T
```

which should output something like this:

```bash
....
rake audited:add_migration      # Installs Sequel::Audited migration, but does not run it.
....
```

Run the sequel-audit rake task:

```bash
bundle exec rake audited:add_migration
```
After this you can comment out the rake task in your Rakefile until you need to update. And then  
finally run db:migrate to update your DB.

```bash
bundle exec rake db:migrate
```


### 3)  Add the `:uuid` plugin

You need to add the `:uuid` plugin to models as follows:

```ruby
 # add a unique uuid token to each record. Used by sequel-audited
 Sequel::Model.plugin(:uuid)
```

...and add a :uuid column to your model migrations (below) to store the unique uuid key for each model.

```ruby
  ...
  column :uuid,             :text
  ...
```

**SideNote**:  I'm using `:uuid` keys here for safer tracking of model records and to circumvent any primary key issues due to `integer` or `string` keys and casting of those within the DB.

<br>


### 4)  Add `:pg_json_ops` and ``pg_json`` extensions

You need to add the `:pg_json` extension to support JSON formatted content before instantiation the DB connection:

```ruby
 # add PG JSON OPS extension. NOTE! before the DB.connect call
 Sequel.extension(:pg_json_ops)
```
and the `:pg_json` extension after the DB connection call.

```ruby
 # add PG JSON extensions NOTE! after the DB.connect call.
 DB.extension :pg_json
```

<br>

### IMPORTANT SIDENOTE!

If you are using PostgreSQL as your database, then it's a good idea to convert the  the `event_data` 
column to JSON type for automatic translations into a Ruby hash.

Otherwise, you have to use `JSON.parse(@v.event_data)` to convert it to a hash if and when you want 
to use it.

<br>

------


## Usage


Using this plugin is fairly simple and straight-forward.  Just add it to the model you wish to 
have audits (versions) for.

```ruby
 # auditing single model
 Post.plugin :audited

 # auditing all models. NOT RECOMMENDED!
 Sequel::Model.plugin :audited
```

By default this will audit / version all columns on the model, **except** the default ignored columns configured in `Sequel::Audited.audited_default_ignored_columns` (see [Configuration Options](#configuration-options) below).

<br>

#### Basic usage => `plugin(:audited)`

```ruby
 # Given a Post model with these columns: 
 [:id, :category_id, :title, :body, :author_id, :created_at, :updated_at]
 
 # Auditing all columns*
 
 Post.plugin :audited 
   
   #=> [:id, :category_id, :title, :body, :author_id] # audited columns
   #=> [:created_at, :updated_at]  # ignored columns
   
```
<br>

#### Advanced Usage => `plugin(:audited, :only => [...])`

```ruby
# Auditing a Single column
  
  Post.plugin :audited, only: [:title]
    
    #=> [:title] # audited columns
    #=> [:id, :category_id, :body, :author_id, :created_at, :updated_at] # ignored columns
      
      
# Auditing Multiple columns
  
  Post.plugin :audited, only: [:title, :body]
    #=> [:title, :body] # audited columns
    #=> [:id, :category_id, :author_id, :created_at, :updated_at] # ignored columns
    
```
<br>

#### Advanced Usage => `plugin(:audited, :except => [...])`

**NOTE!** this option does NOT ignore the default ignored columns, so use with care.

```ruby
# Auditing all columns except specified columns

  Post.plugin :audited, except: [:title]
    
    #=> [:id, :category_id, :author_id, :created_at, :updated_at] # audited columns
    #=> [:title] # ignored columns
  
  
  Post.plugin :audited, except: [:title, :author_id]
    
    #=> [:id, :category_id, :created_at, :updated_at] # audited columns
    #=> [:title, :author_id] # ignored columns

```
<br>

---

<br>


## How it works

You have to look behind the curtain to see what this plugin actually does.

In a new clean DB...

### 1) Create

When you create a new record like this:

```ruby
Category.create(name: 'Sequel')
  #<Category @values={
    :id => 1, 
    :name => "Sequel", 
    :position => 1, 
    :created_at => <timestamp>, 
    :updated_at => nil
  }>

# in the background a new row in DB[:audit_logs] has been added with the following info:

#<AuditLog @values={
  :id => 1, 
  :item_type => "Category", 
  :item_uuid => <UUID>, 
  :event => "create", 
  # NOTE! all model values are stored by default on new records.
  :event_data => "{\"id\":1,\"name\":\"Sequel\",\"created_at\":\"<timestamp>\"}", 
  :version => 1, 
  :user_id => 88, 
  :username => "joeblogs", 
  :user_type => "User", 
  :created_at => <timestamp>
}>
```

### 2) Updates

When you update a record like this:

```ruby
cat.update(name: 'Ruby Sequel')
  #<Category @values={
    :id => 1, 
    :name => "Ruby Sequel", 
    :position => 1, 
    :created_at => <timestamp>, 
    :updated_at => <timestamp>
  }>

# in the background a new row in DB[:audit_logs] has been added with the following info:

#<AuditLog @values={
  :id => 2, 
  :item_type => "Category", 
  :item_uuid => <UUID>,
  :event => "update", 
  # NOTE! only the changes are stored
  :event_data => "{\"name\":[\"Sequel\",\"Ruby Sequel\"]}", 
  :version => 2, 
  :user_id => 88, 
  :username => "joeblogs", 
  :user_type => "User", 
  :created_at => <timestamp>
}>
```


### 3) Destroys (Deletes)

When you delete a record like this:

```ruby
cat.delete

# in the background a new row in DB[:audit_logs] is added with the info:

#<AuditLog @values={
  :id => 3, 
  :item_type => "Category", 
  :item_uuid => <UUID>,
  :event => "destroy",
  # NOTE! all model values are stored by default on deleted records
  :event_data => "{\"id\":1,\"name\":\"Ruby Sequel\",\"created_at\":\"<timestamp>\",\"updated_at\":\"<timestamp>\"}",
  :version => 3, 
  :user_id => 88, 
  :username => "joeblogs", 
  :user_type => "User", 
  :created_at => <timestamp>
}>
```


This way you can **easily track what was created, changed or deleted** and **who did it** and **when they did it**.

<br>

---

<br>


## Configuration Options


**sequel-audited** supports two forms of configurations:

### A) Global configuration options

#### `Sequel::Audited.audited_current_user_method`
    
Sets the name of the global method that provides the current user object. 
Default is: `:current_user`.
    
You can easily change the name of this method by calling:
    
```ruby
Sequel::Audited.audited_current_user_method = :audited_user
```
    
**Note!** the name of the function must be given as a symbol.

<br>    

#### `Sequel::Audited.audited_model_name`

Enables adding your own Audit model. Default is: `:AuditLog`  

```ruby
Sequel::Audited.audited_model_name = :YourCustomModel
```
**Note!** the name of the model must be given as a symbol.

<br>

#### `Sequel::Audited.audited_enabled`

Toggle for enabling / disabling auditing throughout all audited models.
Default is: `true` i.e: enabled.  

<br>


#### `Sequel::Audited.audited_default_ignored_columns`

An array of columns that are ignored by default. Default value is:

```ruby
[:lock_version, :created_at, :updated_at, :created_on, :updated_on]
```
NOTE! `:timestamps` related columns must be ignored or you may end up with situation
where an update triggers multiple copies of the record in the audit log.

<br>


```ruby
# NOTE! array values must be given as symbols.
Sequel::Audited.audited_default_ignored_columns = [:id, :mycolumn, ...]
```

<br>

### B) Per Audited Model configurations

You can also set these settings on a per model setting by passing the following options:

#### `:user_method => :something`

This option will use a different method for the current user within this model only. 

Example:

```ruby
# if you have a global method like 
def current_client
  @current_client ||= Client[session[:client_id]]
end

# and set 
ClientProfile.plugin(:audited, :user_method => :current_client)

# then the user info will be taken from DB[:clients].
 #<Client @values={:id=>99,:username=>"happyclient"... }>
 
```

**NOTE!** the current user model must respond to `:id` and `:username` attributes.

<br>

#### `:default_ignored_columns => [...]`

This option allows you to set custom default ignored columns in the audited model. It's basically
just an option *just-in-case*, but it's probably better to use the `:only => []` or `:except => []` 
options instead (see [Usage](#usage) above).

<br>

----

<br>



## Class Methods

You can easily track all changes made to a model / row / field(s) like this:


### `#.audited_version?`

```ruby  
# check if model have any audits (only works on audited models)
Post.audited_versions?
  #=> returns true / false if any audits have been made
```

### `#.audited_version([conditions])`

```ruby
# grab all audits for a particular model. Returns an array.
Post.audited_versions
  #=> [ 
        { id: 1, item_type: 'Post', item_uuid: '<UUID>', version: 1, 
          event: 'create',  event_data: "{JSON SERIALIZED OBJECT}", 
          user_id: 88, username: "joeblogs", created_at: TIMESTAMP
        },
        {...}
       ]


# filtered by uuid key value
Posts.audited_versions(item_uuid: <UUID>)

# filtered by user :id or :username value
Posts.audited_versions(user_id: 88)
Posts.audited_versions(username: 'joeblogs')

# filtered to last two (2) days only
Posts.audited_versions(:created_at < Date.today - 2)

```



2) Track all changes made by a user / user_group.

```ruby
joe = User[88]

joe.audited_versions  
  #=> returns all audits made by joe  
    ['SELECT * FROM `audit_logs` WHERE user_id = 88 ORDER BY created_at DESC']

joe.audited_versions(:item_type => Post)
  #=> returns all audits made by joe on the Post model
    ['SELECT * FROM `audit_logs` WHERE user_id = 88 AND item_type = 'Post' ORDER BY created_at DESC']
```



## Instance Methods

When you call `.plugin(:audited)` in your model, you get these methods:


### `.versions` 

```ruby
class Post < Sequel::Model
  plugin :audited   # options here
end

# Returns this post's versions.
post.versions  #=> []
```

<br>

### `.blame` 
-- aliased as: `.last_audited_by`

```ruby
# Returns the username of the user who last changed the record
post.blame
post.last_audited_by  #=> 'joeblogs'
```

<br>


### `.last_audited_at` 
-- aliased as: `.last_audited_on`

```ruby
# Returns the timestamp last changed the record
post.last_audited_at
post.last_audited_on  #=> <timestamp>
```

<br>

### Features and functionality to be implemented

Please help out if you would want this sooner than me ;-)

```ruby
# Returns the post (not a version) as it looked at around the the given timestamp.
post.version_at(timestamp)

# Returns the objects (not Versions) as they were between the given times.
post.versions_between(start_time, end_time)

# Returns the post (not a version) as it was most recently.
post.previous_version

# Returns the post (not a version) as it became next.
post.next_version


# Turn Audited on for all posts.
post.audited_on!

# Turn Audited off for all posts.
post.audited_off!
```



<br>

----

<br>


## TODO's

Not everything is perfect or fully formed, so this gem may be in need of the following:

* It needs some **stress testing** and **THREADS support & testing**. Does the gem work in all 
  situations / instances? 
  
  I really would appreciate the wisdom of someone with a good understanding of these type of 
  things. Please help me ensure it's working great at all times.
  
  
* It could probably be cleaned up and made more efficient by a much better programmer than me.
  Please feel free to provide some suggestions or pull-requests.


* Solid **testing and support for more DB's, other than PostgreSQL** currently tested
   against.  Not a priority as I currently have no such requirements. Please feel free to 
   submit a pull-request.
   
* Testing for use with Rails, Sinatra or other Ruby frameworks. I don't see much issues here, but 
   I'm NOT bothered to do this testing as [Roda](http://roda.jeremyevans.net/) is my preferred 
   Ruby framework. Please feel free to submit a pull-request.

* Support for `:on => [:create, :update]` option to limit auditing to only some actions. Not sure 
   if this is really worthwhile, but could be added as a feature. Please feel free to submit a 
   pull-request.

* Support for sweeping (compacting) old updates if there are too many. Not sure how to handle this.
  Suggestions and ideas are most welcome.
  
  I think a simple cron job could extract all records with `event: 'update'` older than a specific
  time period (3 - 6 months) and dump them into something else, instead of adding this feature.
  
  If you are running this on a free app on Heroku, with many and frequent updates, you might want 
  to pay attention to this functionality as there's a 10,000 rows limit on Heroku.
  



## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run 
the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, 
update the version number in `version.rb`, and then run `bundle exec rake release`, which will create 
a git tag for the version, push git commits and tags, and push the `.gem` file to 
[rubygems.org](https://rubygems.org).



## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/kematzy/sequel-audited.

Please run `bundle exec rake coverage` and `bundle exec rake rubocop` on your code before you
send a pull-request.


This project is intended to be a safe, welcoming space for collaboration, and contributors are 
expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.


## License

&copy; Copyright Kematzy, 2015 - 2016

Heavily inspired by:

* the [sequel](https://github.com/jeremyevans/sequel) gem by Jeremy Evans and many others released 
   under the MIT license.

* the [audited](https://github.com/collectiveidea/audited) gem by Brandon Keepers, Kenneth Kalmer, 
  Daniel Morrison, Brian Ryckbost, Steve Richert & Ryan Glover released under the MIT licence.

* the [paper_trail](https://github.com/airblade/paper_trail) gem by Andy Stewart & Ben Atkins 
  released under the MIT license.
    

The gem is available as open source under the terms of the 
[MIT License](http://opensource.org/licenses/MIT).

