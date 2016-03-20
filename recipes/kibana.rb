include_recipe "chef-vault"
data_bag_items = %w(config credentials)
set_default_attributes_from_data_bag("kibana", data_bag_items)

include_recipe 'simple-kibana::user'
include_recipe 'simple-kibana::install'
include_recipe 'simple-kibana::configure'
include_recipe 'nginx'

bash 'install shield plugin' do
  cwd node["kibana"]["config"]["base_dir"]
  code "bin/kibana plugin --install kibana/shield/latest"
end

########################################
# KIBANA SERVICE
########################################

template "/etc/systemd/system/kibana.service" do
  source "kibana.service.erb"
  owner node["kibana"]["user"]
  group node["kibana"]["group"]
end

service "kibana" do
  provider Chef::Provider::Service::Systemd
  supports start: true, restart: true, stop: true, status: true
  action [:enable, :restart]
end

########################################
# NGINX
########################################

htpasswd "/etc/nginx/htpasswd.users" do
  user node['kibana']['access']['username']
  password node['kibana']['access']['password']
  type "sha1"
end

template "#{node['nginx']['dir']}/sites-available/kibana-flashcards" do
  source "nginx.kibana.erb"
  owner node['nginx']['user']
  group node['nginx']['user']
  mode 0644
end

nginx_site 'kibana-flashcards' do
  enable true
end
