ENV['RACK_ENV'] = 'test'
if ENV['COVERAGE']
  require File.join(File.dirname(File.expand_path(__FILE__)), 'sequel_audited_coverage')
  SimpleCov.sequel_audited_coverage
end

$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'sequel/audited'

require 'rubygems'
require 'sqlite3'
require 'pg'

require 'minitest/autorun'
require 'minitest/sequel'
require 'minitest/assert_errors'
require 'minitest/rg'
