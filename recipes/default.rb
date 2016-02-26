#
# Cookbook Name:: flashcards-cookbook
# Recipe:: default
#
# Copyright (C) 2015 YOUR_NAME
#
# All rights reserved - Do Not Redistribute
#

# include_recipe "build-essential"
# include_recipe 'ruby_build'
# include_recipe "imagemagick"
# include_recipe "redisio"
# include_recipe "redisio::enable"
# # include_recipe "phantomjs::default"

# %w(postgresql-libs postgresql-devel openssl-devel libyaml-devel libffi-devel
#    readline-devel zlib-devel gdbm-devel ncurses-devel
#    policycoreutils policycoreutils-python).each do |package_name|
#   package package_name do
#     action :install
#   end
# end

# ruby_build_ruby node['application']['ruby_version'] do
#   prefix_path '/usr/'
#   action :reinstall
#   not_if "test $(ruby -v | grep #{node["application"]["ruby_version"]} | wc -l) = 1"
# end

# gem_package 'bundler' do
#   gem_binary '/usr/bin/gem'
#   options '--no-ri --no-rdoc'
# end

# ########################################
# # Setup deployment ssh keys
# ########################################

# # file "/home/#{node['application']['deploy']['user']}/.ssh/id_rsa.pub" do
# #   content node['application']['public_key']
# #   owner node['application']['deploy']['user']
# #   mode 0600
# # end

# # file "/home/#{node['application']['deploy']['user']}/.ssh/id_rsa" do
# #   content node['application']['deploy_key']
# #   owner node['application']['deploy']['user']
# #   mode 0600
# # end

# directory node['application']['deploy']["deploy_to"] do
#   owner node['application']['deploy']['user']
#   group node['application']['deploy']['user']
#   recursive true
#   mode 0755
#   action :create
# end

# directory "#{node['application']['deploy']["deploy_to"]}/shared" do
#   owner node['application']['deploy']['user']
#   group node['application']['deploy']['user']
#   mode 0755
#   action :create
# end

# # file "#{node['application']['deploy']["deploy_to"]}/wrap-ssh4git.sh" do
# #   content "#!/bin/bash\n/usr/bin/env ssh -o \"StrictHostKeyChecking=no\" -i \"/home/deployer/.ssh/id_rsa\" \$1 \$2\n"
# #   owner node['application']['deploy']['user']
# #   group node['application']['deploy']['user']
# #   mode 0700
# # end

# %w{config system vendor_bundle log pids assets tmp}.each do |dir|
#   directory "#{node['application']['deploy']["deploy_to"]}/shared/#{dir}" do
#     owner node['application']['deploy']['user']
#     group node['application']['deploy']['user']
#     mode 0755
#     action :create
#   end
# end

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
# bash "preparation" do
#   cwd node["application"]["directory"]
#   user node["application"]["username"]
#   code "bundle install"
# end

# ENV variables setup
# Start application server

