#
# Cookbook Name:: flashcards-cookbook
# Recipe:: general
#
# Copyright (C) 2015 YOUR_NAME
#
# All rights reserved - Do Not Redistribute
#

include_recipe "build-essential"

%w(postgresql-libs postgresql-devel openssl-devel libyaml-devel libffi-devel
   readline-devel zlib-devel gdbm-devel ncurses-devel
   policycoreutils policycoreutils-python).each do |package_name|
  package package_name do
    action :install
  end
end



