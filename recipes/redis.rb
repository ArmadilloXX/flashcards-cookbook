#
# Cookbook Name:: flashcards-cookbook
# Recipe:: redis
#
# Copyright (C) 2015 YOUR_NAME
#
# All rights reserved - Do Not Redistribute
#

include_recipe "flashcards-cookbook::general"
include_recipe "redisio"
include_recipe "redisio::enable"
