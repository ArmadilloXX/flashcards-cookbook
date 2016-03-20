include_recipe "java"
include_recipe "chef-sugar"
include_recipe "elasticsearch"

elasticsearch_user "elasticsearch"
elasticsearch_install "elasticsearch" do
  type node["elasticsearch"]["install_type"].to_sym
  dir  node["elasticsearch"]["base_dir"]
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
