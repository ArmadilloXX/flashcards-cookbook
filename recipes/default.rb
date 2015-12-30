#
# Cookbook Name:: flashcards-cookbook
# Recipe:: default
#
# Copyright (C) 2015 YOUR_NAME
#
# All rights reserved - Do Not Redistribute
#

include_recipe "apt"
include_recipe "build-essential"
include_recipe "git::default"
include_recipe "rbenv::default"
include_recipe "rbenv::ruby_build"

rbenv_ruby node["ruby_version"] do
  ruby_version node["ruby_version"]
  global true
end

node["gems"]["webapp"].each do |item|
  rbenv_gem item do
    ruby_version node["ruby_version"]
  end
end

include_recipe 'postgresql::config_initdb'
include_recipe 'postgresql::server'

# Prepare database connection

# Create and prepare database

# Seeding database

# Redis
include_recipe 'redisio'
include_recipe 'redisio::enable'

# Start application server

