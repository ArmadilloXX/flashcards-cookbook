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
include_recipe "phantomjs::default"

rbenv_ruby node["application"]["ruby_version"] do
  ruby_version node["application"]["ruby_version"]
  global true
end

node["application"]["gems_to_install"].each do |item|
  rbenv_gem item do
    ruby_version node["application"]["ruby_version"]
  end
end

########################################
# Sidekiq setup
########################################

# template "/etc/systemd/system/sidekiq.service" do
#   source "sidekiq.service.erb"
#   mode 0644
# end

# service "sidekiq" do
#   supports restart: true, start: true, stop: true
#   action :nothing
# end

# Prepare application
bash "preparation" do
  cwd node["application"]["directory"]
  user node["application"]["username"]
  code "bundle install"
end

# ENV variables setup
# Start application server

