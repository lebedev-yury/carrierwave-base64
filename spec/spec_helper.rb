require 'rubygems'
require 'bundler/setup'

require 'pry'
require 'sham_rack'

require 'rails'
require 'active_record'
require 'mongoid'

require 'carrierwave'
require 'carrierwave/orm/activerecord'
require 'carrierwave/mongoid'

require 'carrierwave/base64'

ActiveRecord::Base.raise_in_transactional_callbacks = true
ActiveRecord::Base.establish_connection(
  adapter: 'sqlite3',
  database: ':memory:'
)

load 'support/schema.rb'
require 'support/models'
require 'support/custom_expectations/warn_expectation'

def file_path(*paths)
  File.expand_path(File.join(File.dirname(__FILE__), *paths))
end

CarrierWave.root = ''
