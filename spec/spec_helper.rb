require 'dotenv'
Dotenv.load(File.expand_path('../../.env.test', __FILE__))

ENV['RACK_ENV'] = 'test'
if ENV['COVERAGE']
  require File.join(File.dirname(File.expand_path(__FILE__)), 'sequel_audited_coverage')
  SimpleCov.sequel_audited_coverage
end

$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)

require 'rubygems'
require 'sqlite3'
require 'pg'

require 'minitest/sequel'
require 'minitest/autorun'
require 'minitest/hooks/default'
class Minitest::HooksSpec
  def around
    Sequel::Model.db.transaction(rollback: :always, auto_savepoint: true) { super }
  end
end

require 'minitest/assert_errors'
require 'minitest/rg'

Sequel.extension(:core_extensions)
# Auto-manage created_at/updated_at fields
Sequel::Model.plugin(:timestamps)

# DB = Sequel.sqlite # :memory
DB = Sequel.connect(ENV['DATABASE_URL'])

puts "Using DB=[#{ENV['DATABASE_URL']}]"


DB.create_table!(:users) do
  primary_key :id
  column :username,         :text
  column :name,             :text
  column :email,            :text
end

DB.create_table!(:audit_logs) do
  primary_key :id
  column :model_type,       :text
  column :model_pk,         :integer
  column :event,            :text
  column :changed,          :text
  column :version,          :integer, default: 0
  column :user_id,          :integer
  column :username,         :text
  column :user_type,        :text, default: 'User'
  column :created_at,       :timestamp
end


DB.create_table!(:posts) do
  primary_key  :id
  column :category_id,      :integer, default: 1
  column :title,            :text
  column :body,             :text
  column :author_id,        :integer
  # timestamps
  column :created_at,       :timestamp
  column :updated_at,       :timestamp
end

DB.create_table!(:categories) do
  primary_key  :id
  column :name,             :text
  column :position,         :integer, default: 1
  # timestamps
  column :created_at,       :timestamp
  column :updated_at,       :timestamp
end

DB.create_table!(:comments) do
  primary_key  :id
  column :post_id,      :integer, default: 1
  column :title,        :text
  column :body,         :text
  # timestamps
  column :created_at,  :timestamp
  column :updated_at,  :timestamp
end

DB.create_table!(:authors) do
  primary_key  :id
  column :name,        :text
  # timestamps
  column :created_at,  :timestamp
  column :updated_at,  :timestamp
end


require 'sequel/audited'

class User < Sequel::Model
end

class Post < Sequel::Model
  many_to_one  :author
  one_to_many  :comments
  many_to_many :categories
  # one_to_one   :main_author, :class=>:Author, :order=>:id
end

class Comment < Sequel::Model
  many_to_one  :post
end

class Author < Sequel::Model
  one_to_many  :posts
end

class Category < Sequel::Model
  many_to_many :posts
end

#  create the user accounts
@u1 = User.create(username: 'joeblogs', name: 'Joe Blogs', email: 'joe@blogs.com')
@u2 = User.create(username: 'janeblogs', name: 'Jane Blogs', email: 'jane@blogs.com')
@u3 = User.create(username: 'auditeduser', name: 'Audited User', email: 'auditeduser@blogs.com')

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

ca1 = Category.create(name: 'Category 1')
ca2 = Category.create(name: 'Category 2')
ca3 = Category.create(name: 'Category 3')
ca4 = Category.create(name: 'Category 4')

a1 = Author.create(name: 'Author 1')
a2 = Author.create(name: 'Author 2')

p1 = Post.create(title: 'Post 1', author_id: a1.id, category_id: ca1.id)
p2 = Post.create(title: 'Post 2', author_id: a1.id, category_id: ca2.id)
p3 = Post.create(title: 'Post 3', author_id: a2.id, category_id: ca3.id)
p4 = Post.create(title: 'Post 4', author_id: a2.id, category_id: ca4.id)

co1 = Comment.create(title: 'Comment 1', body: 'Comment 1 body', post_id: p1.id)
co2 = Comment.create(title: 'Comment 2', body: 'Comment 2 body', post_id: p1.id)
co3 = Comment.create(title: 'Comment 3', body: 'Comment 3 body', post_id: p1.id)
co4 = Comment.create(title: 'Comment 4', body: 'Comment 4 body', post_id: p2.id)
co5 = Comment.create(title: 'Comment 5', body: 'Comment 5 body', post_id: p2.id)
co6 = Comment.create(title: 'Comment 6', body: 'Comment 6 body', post_id: p2.id)

