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
include_recipe "imagemagick"

rbenv_ruby node["webapp"]["ruby_version"] do
  ruby_version node["webapp"]["ruby_version"]
  global true
end

node["webapp"]["gems_to_install"].each do |item|
  rbenv_gem item do
    ruby_version node["webapp"]["ruby_version"]
  end
end

include_recipe "postgresql::server"
include_recipe "database::postgresql"

# Prepare database connection
postgresql_connection_info = {
  host: node["postgresql"]["config"]["listen_addresses"],
  port: node["postgresql"]["config"]["port"],
  username: "postgres",
  password: node["postgresql"]["password"]["postgres"]
}

# Create database superuser
postgresql_database_user node["webapp"]["username"] do
  connection postgresql_connection_info
  superuser true
  action :create
end

# Add default db config file

# Prepare application and databases
bash "preparation" do
  cwd node["webapp"]["directory"]
  user node["webapp"]["username"]
  code <<-CMDS
    bundle install
    rake db:create
    rake db:migrate
    rake db:seed
  CMDS
end

# ENV variables setup

# Redis
include_recipe "redisio"
include_recipe "redisio::enable"

# Start application server

