if node["application"]['override_config_from_data_bag']
  include_recipe "chef-vault"
  override_settings_from_data_bag('flashcards', 'flashcards_config')
  override_settings_from_data_bag('flashcards', 'flashcards_secrets')
end

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

node["elasticsearch"]["users"].each do |user|
  base_dir = "/usr/share/elasticsearch/bin/shield"
  bash "create \'#{user["username"]}\' user" do
    cwd base_dir
    code "./esusers useradd #{user["username"]} -r #{user["role"]} -p #{user["password"]}"
    not_if "test $(#{base_dir}/esusers list | grep #{user["username"]} | wc -l) = 1"
  end
end

elasticsearch_service "elasticsearch" do
  action :start
end
