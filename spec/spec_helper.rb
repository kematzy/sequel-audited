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
require 'minitest/assert_errors'
require 'minitest/rg'


# Auto-manage created_at/updated_at fields
Sequel::Model.plugin(:timestamps)
# The preferred default validations plugin, which uses instance-level methods.
# Sequel::Model.plugin(:validation_helpers)

DB = Sequel.sqlite # :memory
# DB = Sequel.connect("sqlite://#{File.dirname(__FILE__)}/test.db")# :memory

DB.create_table?(:users) do
  primary_key :id
  column :username,         :string
  column :name,             :string
  column :email,            :string
end

DB.create_table?(:audit_logs) do
  primary_key :id
  column :model_type,       :string
  column :model_pk,         :string
  column :event,            :string
  column :changed,          :text
  column :version,          :integer, default: 0
  column :user_id,          :integer
  column :username,         :string
  column :user_type,        :string, default: 'User'
  column :created_at,       :datetime
end


DB.create_table?(:posts) do
  primary_key  :id
  Integer :category_id, default: 1
  # migration here...
  String  :title, size: 255
  String  :body,  text: true
  Integer :author_id
  
  # timestamps
  DateTime :created_at
  DateTime :updated_at
end

DB.create_table?(:categories) do
  primary_key  :id
  String  :name
  Integer :position, default: 1
  
  # timestamps
  DateTime :created_at
  DateTime :updated_at
end

DB.create_table?(:comments) do
  primary_key  :id
  Integer :post_id, default: 1
  String  :title, size: 255
  String  :body, text: true
  
  # timestamps
  DateTime :created_at
  DateTime :updated_at
end

DB.create_table?(:authors) do
  primary_key  :id
  String :name
  
  # timestamps
  DateTime :created_at
  DateTime :updated_at
end


# require_relative '../lib/sequel-audit/migration'
# require_relative '../tasks/sequel-audited/templates/audited_migration'
# DB.instance_eval(&AuditMigration.migrate)

require 'sequel/audited'


# User class
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

class Dummy < Sequel::Model
  
end

#  create the user accounts
@u1 = User.create(username: 'joeblogs', name: 'Joe Blogs', email: 'joe@blogs.com')
@u2 = User.create(username: 'janeblogs', name: 'Jane Blogs', email: 'jane@blogs.com')
@u3 = User.create(username: 'auditeduser', name: 'Audited User', email: 'auditeduser@blogs.com')

$current_user = @u1
$audited_user = @u3

def current_user
  $current_user
end
def audited_user
  $audited_user
end

# def current_user(u = nil)
#   # @current_user = nil
#   if @current_user
#     return @current_user
#   else
#     if u.nil?
#       @current_user = User.first
#     elsif u
#       @current_user = u
#     end
#     return @current_user
#   end
#   # @current_user
#   # @current_user ||= u.nil? ? User.first : u
# end



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


class Minitest::HooksSpec
  
  around(:all) do |&block|
    DB.transaction(rollback: :always) { super(&block) }
  end

  around do |&block|
    DB.transaction(rollback: :always, savepoint: true, auto_savepoint: true) { super(&block) }
  end

end
