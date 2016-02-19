#
# Cookbook Name:: flashcards-cookbook
# Recipe:: default
#
# Copyright (C) 2015 YOUR_NAME
#
# All rights reserved - Do Not Redistribute
#

include_recipe "build-essential"
include_recipe "rbenv::default"
include_recipe "rbenv::ruby_build"
include_recipe "imagemagick"
include_recipe "redisio"
include_recipe "redisio::enable"

rbenv_ruby node["webapp"]["ruby_version"] do
  ruby_version node["webapp"]["ruby_version"]
  global true
end

node["webapp"]["gems_to_install"].each do |item|
  rbenv_gem item do
    ruby_version node["webapp"]["ruby_version"]
  end
end

# Prepare application
bash "preparation" do
  cwd node["webapp"]["directory"]
  user node["webapp"]["username"]
  code "bundle install"
end

# ENV variables setup
# Start application server

