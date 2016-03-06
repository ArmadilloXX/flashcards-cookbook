#
# Cookbook Name:: flashcards-cookbook
# Recipe:: application
#
# Copyright (C) 2015 YOUR_NAME
#
# All rights reserved - Do Not Redistribute
#

include_recipe "flashcards-cookbook::general"
include_recipe 'ruby_build'
include_recipe 'nginx'
include_recipe "imagemagick"
include_recipe "chef-vault"
# include_recipe "phantomjs::default"

ruby_build_ruby node['application']['ruby_version'] do
  prefix_path '/usr/'
  action :reinstall
  not_if "test $(ruby -v | grep #{node["application"]["ruby_version"]} | wc -l) = 1"
end

gem_package 'bundler' do
  gem_binary '/usr/bin/gem'
  options '--no-ri --no-rdoc'
end

# user_account node['app-rails']['deploy']['user'] do
#   create_group true
#   ssh_keygen false
# end

########################################
# NGINX
########################################

template "#{node['nginx']['dir']}/sites-available/#{node['application']['name']}" do
  source "nginx.#{node['application']['app_server']}.erb"
  owner node['nginx']['user']
  group node['nginx']['user']
  mode 0644
end

# if node["application"]["ssl"]
#   file "#{node['nginx']['dir']}/#{node['application']['name']}.crt" do
#     content node['application']['ssl_crt']
#     owner node['nginx']['user']
#     group node['nginx']['user']
#     mode 0644
#     only_if { node['application']['ssl'] }
#   end

#   file "#{node['nginx']['dir']}/#{node['application']['name']}.key" do
#     content node['application']['ssl_key']
#     mode 0644
#     owner node['nginx']['user']
#     group node['nginx']['user']
#     only_if { node['application']['ssl'] }
#   end
# end

nginx_site node['application']['name'] do
  enable true
end

########################################
# Setup deployment ssh keys
########################################

# file "/home/#{node['application']['deploy']['user']}/.ssh/id_rsa.pub" do
#   content node['application']['public_key']
#   owner node['application']['deploy']['user']
#   mode 0600
# end

# file "/home/#{node['application']['deploy']['user']}/.ssh/id_rsa" do
#   content node['application']['deploy_key']
#   owner node['application']['deploy']['user']
#   mode 0600
# end

directory node['application']['deploy']["deploy_to"] do
  owner node['application']['deploy']['user']
  group node['application']['deploy']['user']
  recursive true
  mode 0755
  action :create
end

directory "#{node['application']['deploy']["deploy_to"]}/shared" do
  owner node['application']['deploy']['user']
  group node['application']['deploy']['user']
  mode 0755
  action :create
end

# file "#{node['application']['deploy']["deploy_to"]}/wrap-ssh4git.sh" do
#   content "#!/bin/bash\n/usr/bin/env ssh -o \"StrictHostKeyChecking=no\" -i \"/home/deployer/.ssh/id_rsa\" \$1 \$2\n"
#   owner node['application']['deploy']['user']
#   group node['application']['deploy']['user']
#   mode 0700
# end

%w{config system vendor_bundle log pids assets tmp}.each do |dir|
  directory "#{node['application']['deploy']["deploy_to"]}/shared/#{dir}" do
    owner node['application']['deploy']['user']
    group node['application']['deploy']['user']
    mode 0755
    action :create
  end
end

########################################
# App server setup
########################################

app_server = node["application"]["app_server"]

template "/opt/httpd_unix_sockets.te" do
  source "httpd_unix_sockets.te.erb"
end

bash "install_selinux_httpd_unix_module" do
  code <<-EOF
    checkmodule -M -m -o /opt/httpd_unix_sockets.mod /opt/httpd_unix_sockets.te
    semodule_package -o /opt/httpd_unix_sockets.pp -m /opt/httpd_unix_sockets.mod
    semodule -i /opt/httpd_unix_sockets.pp
  EOF
  not_if { ::File.exists?("/opt/httpd_unix_sockets.pp") }
end

template "/etc/systemd/system/#{node['application']["name"]}-#{app_server}.service" do
  source "#{app_server}.service.erb"
  owner node['application']['deploy']['user']
  group node['application']['deploy']['user']
end

service "#{node['application']["name"]}-#{app_server}" do
  provider Chef::Provider::Service::Systemd
  action :enable
end

template "#{node['application']['deploy']["deploy_to"]}/shared/config/#{app_server}.rb" do
  source "#{app_server}.rb.erb"
  owner node['application']['deploy']['user']
  group node['application']['deploy']['user']
end

########################################
# Sidekiq setup
########################################

template "/etc/systemd/system/sidekiq.service" do
  source "sidekiq.service.erb"
  mode 0644
end

service "sidekiq" do
  supports restart: true, start: true, stop: true
  action :nothing
end

########################################
# Application environment variables
########################################

chef_vault_secret 'new_credentials' do
  data_bag 'database'
  raw_data({'user' => 'test_user', 'password' => 'testpass'})
  admins 'admin'
  clients 'application-192.168.50.101'
  search '*:*'
end

# vault = chef_vault_item('credentials', 'database')

template "#{node['application']['deploy']["deploy_to"]}/shared/.env" do
  source "dotenv.erb"
  owner node['application']['deploy']['user']
  group node['application']['deploy']['user']
  mode 0644
  variables(
    vars: node['application']['env_vars'].merge({
      "DATABASE_HOSTNAME" => node['application']["database"]["host"],
      "DATABASE_NAME"     => node['application']["database"]["name"],
      "DATABASE_PASSWORD" => node['application']["database"]["password"],
      "DATABASE_PORT"     => node['application']["database"]["port"],
      "DATABASE_USERNAME" => node['application']["database"]['user']
      # "TEST_USER" => vault['user'],
      # "TEST_PASSWORD" => vault['password']
    })
  )
end
# Start application server

