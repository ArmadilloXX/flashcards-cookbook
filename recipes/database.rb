#
# Cookbook Name:: flashcards-cookbook
# Recipe:: database
#
# Copyright (C) 2015 YOUR_NAME
#
# All rights reserved - Do Not Redistribute
#

include_recipe "flashcards-cookbook::general"
include_recipe "postgresql::server"
include_recipe "database::postgresql"

# Prepare database connection
postgresql_connection_info = {
  host: node["postgresql"]["config"]["listen_addresses"],
  port: node["postgresql"]["config"]["port"],
  username: node["postgresql"]["username"]["postgres"],
  password: node["postgresql"]["password"]["postgres"]
}

# Create application database user
postgresql_database_user node["application"]["database"]["username"] do
  connection postgresql_connection_info
  superuser true # TODO Grant privileges instead of create superuser
  password node["application"]["database"]["password"]
  action :create
end

# Add default db config file

# Prepare databases
# bash "preparation" do
#   cwd node["webapp"]["directory"]
#   user node["webapp"]["username"]
#   code <<-CMDS
#     rake db:create
#     rake db:migrate
#     rake db:seed
#   CMDS
# end


