include_recipe "chef-vault"
data_bag_items = %w(config credentials)
set_default_attributes_from_data_bag("kibana", data_bag_items)

# include_recipe 'simple-kibana::user'
include_recipe 'simple-kibana::install'
include_recipe 'simple-kibana::configure'
# include_recipe 'nginx'

# bash "install public key" do
#   code "rpm --import https://packages.elastic.co/GPG-KEY-elasticsearch"
# end

# template "/etc/yum.repos.d/kibana.repo" do
#   source "kibana.repo.erb"
# end

# yum_package "kibana"

directory "#{node["kibana"]["dir"]}/kibana-#{node["kibana"]["version"]}/ssl" do
  owner node['kibana']['user']
  group node['kibana']['user']
  recursive true
  mode 0755
  action :create
end

ssl_crt = data_bag_item("certificates", "ssl_crt").to_hash
ssl_key = data_bag_item("certificates", "ssl_key").to_hash

file "#{node["kibana"]["dir"]}/kibana-#{node["kibana"]["version"]}/ssl/flashcards.crt" do
  content ssl_crt["crt"]
  owner node['kibana']['user']
  group node['kibana']['user']
  mode 0644
  # only_if { node['application']['ssl'] }
end

file "#{node["kibana"]["dir"]}/kibana-#{node["kibana"]["version"]}/ssl/flashcards.key" do
  content ssl_key["key"]
  mode 0644
  owner node['kibana']['user']
  group node['kibana']['user']
  # only_if { node['application']['ssl'] }
end

bash 'install shield plugin' do
  base_dir = "#{node["kibana"]["dir"]}/kibana-#{node["kibana"]["version"]}"
  plugin_dir = "#{base_dir}/installedPlugins"
  cwd base_dir
  code "bin/kibana plugin --install kibana/shield/latest"
  user node["kibana"]["user"]
  not_if { ::Dir.exists?("#{plugin_dir}/shield")}
end

########################################
# KIBANA SERVICE
########################################

template "/etc/systemd/system/flashcards-kibana.service" do
  source "kibana.service.erb"
  owner node["kibana"]["user"]
  group node["kibana"]["group"]
end

service "flashcards-kibana" do
  provider Chef::Provider::Service::Systemd
  supports start: true, restart: true, stop: true, status: true
  action [:enable, :start]
end

########################################
# NGINX
########################################

# htpasswd "/etc/nginx/htpasswd.users" do
#   user node['kibana']['access']['username']
#   password node['kibana']['access']['password']
#   type "sha1"
# end

# template "#{node['nginx']['dir']}/sites-available/kibana-flashcards" do
#   source "nginx.kibana.erb"
#   owner node['nginx']['user']
#   group node['nginx']['user']
#   mode 0644
# end

# nginx_site 'kibana-flashcards' do
#   enable true
# end
