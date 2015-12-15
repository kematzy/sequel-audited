# Sequel::Audited

## Key Objectives

1) Track all changes made to a model / row / field(s).

```ruby  
# grab all audits for a particular model
Post.audited_versions
  #=> [ {version: 1, model: Post, pk: 11, changes: "{JSON SERIALIZED OBJECT}", changed_by: user_id, created_at: TIMESTAMP,... },...]

Post.audited_versions?
  #=> returns true / false if any audits have been made

Post.audited_versions( filter conditions )
  #=> ability to filter to last 2 / 7 / 30 days changes OR by user / by pk

Posts.audited_versions(:pk => 123)
  #=> filtered by primary_key value
  
Posts.audited_versions(:user_id => 88)
  #=> filtered by user name
  
Posts.audited_versions(:created_at < Date.today - 2)
  #=> filtered to last two (2) days only
  
Posts.audited_versions(:created_at > Date.today - 7)
  #=> filtered to older than last seven (7) days
```



2) Track all changes made by a user / user_group.

```ruby
joe = User[88]

joe.audited_versions  
  #=> returns all audits made by joe  
    ['SELECT * FROM `audit_versions` WHERE user_id = 88 ORDER BY created_at DESC']

joe.audited_versions(:model => Post)
  #=> returns all audits made by joe on the Post model
    ['SELECT * FROM `audit_versions` WHERE user_id = 88 AND model = 'Post' ORDER BY created_at DESC']
```



## Key Ideas

###  Model & Primary_key

Verify that every model can access a primary key value [field(s)] and then store that value.

```ruby
user = User[88]

# 
self.model & self.pk
{ 
  version: self.version + 1, 
  model: self.model, 
  pk: self.pk, 
  changes: self.previous_changes.to_json, 
  changed_by: self.updated_by || current_user.id, 
  created_at: timestamps
}
```


### 




## API Summary

When you declare :audit_trail in your model, you get these methods:

```ruby
class Widget < Sequel::Model
  plugin :audited   # you can pass various options here
end

# Returns this widget's audited_versions.  You can customise the name of the association.
widget.audited_versions

# Return the version this widget was reified from, or nil if it is live.
# You can customise the name of the method.
widget.version

# Returns true if this widget is the current, live one; or false if it is from a previous version.
widget.live?

# Returns who put the widget into its current state.
widget.originator

# Returns the widget (not a version) as it looked at the given timestamp.
widget.version_at(timestamp)

# Returns the objects (not Versions) as they were between the given times.
widget.versions_between(start_time, end_time)

# Returns the widget (not a version) as it was most recently.
widget.previous_version

# Returns the widget (not a version) as it became next.
widget.next_version

# Generates a version for a `touch` event (`widget.touch` does NOT generate a version)
widget.touch_with_version

# Turn Audited off for all widgets.
Widget.audited_off!

# Turn Audited on for all widgets.
Widget.audited_on!

# Check whether Audited is enabled for all widgets.
Widget.audited_enabled_for_model?
widget.audited_enabled_for_model? # only available on instances of versioned models
```







Welcome to your new gem! In this directory, you'll find the files you need to be able to package up 
your Ruby library into a gem. Put your Ruby code in the file `lib/sequel/audited`. To experiment with 
that code, run `bin/console` for an interactive prompt.

TODO: Delete this and the text above, and describe your gem

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'sequel-audited'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install sequel-audited

## Usage

TODO: Write usage instructions here

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run 
the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, 
update the version number in `version.rb`, and then run `bundle exec rake release`, which will create 
a git tag for the version, push git commits and tags, and push the `.gem` file to 
[rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/sequel-audited. 
This project is intended to be a safe, welcoming space for collaboration, and contributors are 
expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the 
[MIT License](http://opensource.org/licenses/MIT).

