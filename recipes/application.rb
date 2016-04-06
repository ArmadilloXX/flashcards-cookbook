include_recipe "chef-vault"
data_bag_items = %w(config credentials)
set_default_attributes_from_data_bag("application", data_bag_items)

include_recipe "flashcards-cookbook::general"
include_recipe "ruby_build"
include_recipe 'nginx'
include_recipe "imagemagick"

ruby_build_ruby node["application"]["ruby_version"] do
  prefix_path "/usr/"
  action :reinstall
  not_if "test $(ruby -v | grep #{node['application']['ruby_version']} | wc -l) = 1"
end

gem_package "bundler" do
  gem_binary "/usr/bin/gem"
  options "--no-ri --no-rdoc"
end

user_account node['application']['deploy']['user'] do
  create_group true
  ssh_keygen false
end

########################################
# NGINX
########################################

template "#{node['nginx']['dir']}/sites-available/#{node['application']['name']}" do
  source "nginx.#{node['application']['app_server']}.erb"
  owner node['nginx']['user']
  group node['nginx']['user']
  mode 0644
end

if node["application"]["ssl"]
  ssl_crt = data_bag_item("certificates", "ssl_crt").to_hash
  ssl_key = data_bag_item("certificates", "ssl_key").to_hash

  file "#{node['nginx']['dir']}/#{node['application']['name']}.crt" do
    content ssl_crt["crt"]
    owner node['nginx']['user']
    group node['nginx']['user']
    mode 0644
    only_if { node['application']['ssl'] }
  end

  file "#{node['nginx']['dir']}/#{node['application']['name']}.key" do
    content ssl_key["key"]
    mode 0644
    owner node['nginx']['user']
    group node['nginx']['user']
    only_if { node['application']['ssl'] }
  end
end

nginx_site node['application']['name'] do
  enable true
end

########################################
# Setup deployment ssh keys
########################################

public_key = data_bag_item("ssh", "public_key").to_hash
deploy_key = data_bag_item("ssh", "deploy_key").to_hash

file "/home/#{node['application']['deploy']['user']}/.ssh/id_rsa.pub" do
  content public_key["key"]
  owner node['application']['deploy']['user']
  group node['application']['deploy']['user']
  mode 0600
end

file "/home/#{node['application']['deploy']['user']}/.ssh/id_rsa" do
  content deploy_key["key"]
  owner node['application']['deploy']['user']
  group node['application']['deploy']['user']
  mode 0600
end

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

file "#{node['application']['deploy']["deploy_to"]}/wrap-ssh4git.sh" do
  content "#!/bin/bash\n/usr/bin/env ssh -o \"StrictHostKeyChecking=no\" -i \"/home/#{node['application']['deploy']['user']}/.ssh/id_rsa\" \$1 \$2\n"
  owner node['application']['deploy']['user']
  group node['application']['deploy']['user']
  mode 0700
end

%w{config system vendor_bundle log pids assets tmp}.each do |dir|
  directory "#{node['application']['deploy']["deploy_to"]}/shared/#{dir}" do
    owner node['application']['deploy']['user']
    group node['application']['deploy']['user']
    recursive true
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
  supports restart: true, start: true, stop: true
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

template "/etc/systemd/system/#{node['application']["name"]}-sidekiq.service" do
  source "sidekiq.service.erb"
  mode 0644
end

service "#{node['application']["name"]}-sidekiq" do
  supports restart: true, start: true, stop: true
  action :nothing
end

########################################
# Application environment variables
########################################

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
    })
  )
end
