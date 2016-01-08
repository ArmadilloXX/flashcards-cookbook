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

include_recipe 'postgresql::server'
include_recipe "database::postgresql"
# include_recipe 'postgresql::config_initdb'

# Prepare database connection
postgresql_connection_info = {host: "127.0.0.1",
                              port: node['postgresql']['config']['port'],
                              username: 'postgres',
                              password: node['postgresql']['password']['postgres']}

# Create 'vagrant' database superuser
postgresql_database_user 'vagrant' do
  connection postgresql_connection_info
  superuser true
  action :create
end

execute 'bundle_install' do
  cwd '/home/vagrant/flashcards'
  command 'bundle install'
  user 'vagrant'
end

# Create databases
execute 'create_db' do
  cwd '/home/vagrant/flashcards'
  user 'vagrant'
  command 'rake db:create'
end

# Migrating database
execute 'migrate_db' do
  cwd '/home/vagrant/flashcards'
  user 'vagrant'
  command 'rake db:migrate'
end

# Seeding database
execute 'seed_db' do
  cwd '/home/vagrant/flashcards'
  user 'vagrant'
  command 'rake db:seed'
end

# ENV variables setup

# Redis
include_recipe 'redisio'
include_recipe 'redisio::enable'

# Start application server

