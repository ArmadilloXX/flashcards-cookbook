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
  download_checksum node["elasticsearch"]["download_checksum"]
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

users = data_bag_item("elasticsearch", "users").to_hash
base_dir = "/usr/share/elasticsearch/bin/shield"
users["users"].each do |user|
  bash "create \'#{user["username"]}\' user" do
    cwd base_dir
    code "./esusers useradd #{user["username"]} -r #{user["role"]} -p #{user["password"]}"
    not_if "test $(#{base_dir}/esusers list | grep #{user["username"]} | wc -l) = 1"
  end
end

elasticsearch_service "elasticsearch" do
  action :start
end
