include_recipe "chef-vault"
data_bag_items = %w(config)
set_default_attributes_from_data_bag("elasticsearch", data_bag_items)

include_recipe "java"
include_recipe "chef-sugar"
include_recipe "elasticsearch"

elasticsearch_user "elasticsearch"
elasticsearch_install "elasticsearch" do
  type :package
  version node["elasticsearch"]["version"]
  download_url node["elasticsearch"]["download_url"]
  download_checksum node["elasticsearch"]["checksum"]
end

elasticsearch_plugin 'license' do
  action :install
end

elasticsearch_plugin 'shield' do
  action :install
end

elasticsearch_configure "elasticsearch" do
  configuration ({
    "network.bind_host" => 0,
    "network.host" => "0.0.0.0",
    "script.inline" => "sandbox",
    "script.aggs" => "on"
  })
end

bash 'create users' do
  cwd "/usr/share/elasticsearch/bin/shield"
  code <<-EOH
    ./esusers useradd es_admin -r admin -p testpass
    ./esusers useradd kibana4-server -r kibana4_server -p password
    ./esusers useradd testuser -r kibana4 -p testpass
  EOH
end

elasticsearch_service "elasticsearch" do
  action :start
end
