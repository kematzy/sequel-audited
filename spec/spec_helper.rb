
require "dotenv"
Dotenv.load(File.expand_path("../../.env.test", __FILE__))

ENV["RACK_ENV"] = "test"
if ENV["COVERAGE"]
  require File.join(File.dirname(File.expand_path(__FILE__)), "sequel_audited_coverage")
  SimpleCov.sequel_audited_coverage
end

$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)

require "rubygems"
require "pg"
require "json"

require "minitest/autorun"
require "minitest/sequel"
require "minitest/hooks/default"
class Minitest::HooksSpec
  around(:all) do |&block|
    DB.transaction(rollback: :always) { super(&block) }
  end
  around do |&block|
    DB.transaction(rollback: :always, savepoint: true, auto_savepoint: true) { super(&block) }
  end
end

require "minitest/assert_errors"
require "minitest/rg"

Sequel.extension(:core_extensions)
Sequel.extension(:blank)
# Auto-manage created_at/updated_at fields
Sequel::Model.plugin(:timestamps)
# add a unique uuid token to each record. Used by sequel-audited
# Sequel::Model.plugin(:uuid, field: :id)
#
Sequel.extension(:pg_json_ops)

# DB = Sequel.sqlite # :memory
DB = Sequel.connect(ENV["DATABASE_URL"])

# add PG extensions
# DB.extension :pg_array, :pg_json
DB.extension :pg_json

# require "logger"
# DB.loggers << Logger.new($stdout)

puts "Using DB=[#{ENV['DATABASE_URL']}]"


DB.create_table!(:users) do
  primary_key :id, :uuid #, null: false
  column :username,         :text
  column :name,             :text
  column :email,            :text
  # column :uuid,             :text
end

DB.create_table!(:audit_logs) do
  primary_key :id
  column :event,            :text

  column :item_type,        :text
  column :item_uuid,        :uuid
  column :version,          :integer
  column :changed,          :json

  column :user_id,          :uuid
  column :username,         :text
  column :user_type,        :text, default: "User"

  column :created_at,       :timestamp
end


DB.create_table!(:posts) do
  primary_key :id, :uuid
  column :category_id,      :uuid
  column :title,            :text
  column :body,             :text
  column :urlslug,          :text, unique: true
  column :author_id,        :uuid
  # timestamps
  column :created_at,       :timestamp
  column :updated_at,       :timestamp
end

DB.create_table!(:blog_posts) do
  primary_key :id, :uuid
  column :author_id,        :uuid
  column :category_id,      :uuid
  column :title,            :text
  column :body,             :text
  column :urlslug,          :text, unique: true
  # timestamps
  column :created_at,       :timestamp
  column :updated_at,       :timestamp
end

DB.create_table!(:categories) do
  primary_key :id, :uuid
  column :name,             :text
  column :position,         :integer, default: 1
  column :urlslug,          :text, unique: true
  # timestamps
  column :created_at,       :timestamp
  column :updated_at,       :timestamp
end

DB.create_table!(:comments) do
  primary_key :id, :uuid
  column :post_id,          :uuid
  column :title,            :text
  column :body,             :text
  column :name,             :text
  column :email,            :text

  # timestamps
  column :created_at,       :timestamp
  column :updated_at,       :timestamp
end

DB.create_table!(:authors) do
  primary_key :id, :uuid
  column :name,             :text
  column :urlslug,          :text, unique: true
  # timestamps
  column :created_at,       :timestamp
  column :updated_at,       :timestamp
end

require "sequel/audited"

class User < Sequel::Model
  plugin(:uuid, field: :id)
end

class Post < Sequel::Model
  plugin(:uuid, field: :id)
  many_to_one  :author, keys: [:author_id]
  one_to_many  :comments, keys: [:comment_id]
  many_to_one  :category, keys: [:category_id]
  # one_to_one   :main_author, :class=>:Author, :order=>:id
  def before_validation
    self.urlslug = title.to_s.downcase.gsub(%r{(\s+|\?|\:|\\|/)}, "-") if urlslug.blank?
    super
  end
end

class BlogPost < Sequel::Model
  plugin(:uuid, field: :id)
  many_to_one  :author, keys: [:author_id]
  one_to_many  :comments, keys: [:comment_id]
  many_to_one  :category, keys: [:category_id]
  def before_validation
    self.urlslug = title.to_s.downcase.gsub(%r{(\s+|\?|\:|\\|/)}, "-") if urlslug.blank?
    super
  end
end

class Comment < Sequel::Model
  plugin(:uuid, field: :id)
  many_to_one  :post, keys: [:comment_id]
end

class Author < Sequel::Model
  plugin(:uuid, field: :id)
  one_to_many  :posts, keys: [:author_id]
  def before_validation
    self.urlslug = name.to_s.downcase.gsub(%r{(\s+|\?|\:|\\|/)}, "-") if urlslug.blank?
    super
  end
end

class Category < Sequel::Model
  plugin(:uuid, field: :id)
  many_to_many :posts, keys: [:category_id]
  def before_validation
    self.urlslug = name.to_s.downcase.gsub(%r{(\s+|\?|\:|\\|/)}, "-") if urlslug.blank?
    super
  end
end

#  create the user accounts
@u1 = User.create(username: "joeblogs", name: "Joe Blogs", email: "joe@blogs.com")
@u2 = User.create(username: "janeblogs", name: "Jane Blogs", email: "jane@blogs.com")
@u3 = User.create(username: "auditeduser", name: "Audited User", email: "auditeduser@blogs.com")

# set global variables for these tests only
$current_user = @u1
$audited_user = @u3

def current_user
  $current_user
end
def audited_user
  $audited_user
end

### DB SEEDS ###

ca1 = Category.create(name: "Category 1")
ca2 = Category.create(name: "Category 2")
ca3 = Category.create(name: "Category 3")
ca4 = Category.create(name: "Category 4")

a1 = Author.create(name: "Author 1")
a2 = Author.create(name: "Author 2")

p1 = Post.create(title: "Post 1", author_id: a1.id, category_id: ca1.id)
p2 = Post.create(title: "Post 2", author_id: a1.id, category_id: ca2.id)
p3 = Post.create(title: "Post 3", author_id: a2.id, category_id: ca3.id)
p4 = Post.create(title: "Post 4", author_id: a2.id, category_id: ca4.id)

co1 = Comment.create(title: "Comment 1", body: "Comment 1 body", post_id: p1.id, name: @u1.name, email: @u1.email)
co2 = Comment.create(title: "Comment 2", body: "Comment 2 body", post_id: p1.id, name: @u2.name, email: @u2.email)
co3 = Comment.create(title: "Comment 3", body: "Comment 3 body", post_id: p1.id, name: @u3.name, email: @u3.email)
co4 = Comment.create(title: "Comment 4", body: "Comment 4 body", post_id: p2.id, name: @u1.name, email: @u1.email)
co5 = Comment.create(title: "Comment 5", body: "Comment 5 body", post_id: p2.id, name: @u2.name, email: @u2.email)
co6 = Comment.create(title: "Comment 6", body: "Comment 6 body", post_id: p2.id, name: @u3.name, email: @u3.email)
