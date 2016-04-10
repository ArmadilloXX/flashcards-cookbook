include_recipe "chef-vault"
# data_bag_items = %w(config credentials)
# set_default_attributes_from_data_bag("kibana", data_bag_items)
override_settings_from_data_bag('flashcards', 'flashcards_config')
override_settings_from_data_bag('flashcards', 'flashcards_secrets')

include_recipe 'simple-kibana::user'
include_recipe 'simple-kibana::install'
include_recipe 'simple-kibana::configure'

########################################
# KIBANA SHIELD PLUGIN AND SSL
########################################
kibana_dir = "#{node["kibana"]["dir"]}/kibana-#{node["kibana"]["version"]}"

directory "#{kibana_dir}/ssl" do
  owner node['kibana']['user']
  group node['kibana']['user']
  recursive true
  mode 0755
  action :create
end

file "#{kibana_dir}/ssl/flashcards.crt" do
  content node["application"]["ssl_cert"]["crt"]
  owner node['kibana']['user']
  group node['kibana']['user']
  mode 0644
end

file "#{kibana_dir}/ssl/flashcards.key" do
  content content node["application"]["ssl_cert"]["key"]
  mode 0644
  owner node['kibana']['user']
  group node['kibana']['user']
end

bash 'install shield plugin' do
  cwd kibana_dir
  code "bin/kibana plugin --install kibana/shield/latest"
  user node["kibana"]["user"]
  group node["kibana"]["user"]
  not_if { ::Dir.exists?("#{kibana_dir}/installedPlugins/shield")}
end

########################################
# KIBANA SERVICE
########################################

template "/etc/systemd/system/#{node["application"]["name"]}-kibana.service" do
  source "kibana.service.erb"
  owner node["kibana"]["user"]
  group node["kibana"]["group"]
end

service "flashcards-kibana" do
  provider Chef::Provider::Service::Systemd
  supports start: true, restart: true, stop: true, status: true
  action [:enable, :start]
end
