include_recipe "chef-vault"
data_bags = %w(general config credentials)
set_item_attributes_from_data_bags(data_bags, "postgresql")
pg_conf_records = data_bag_item("credentials", "pg_conf_records").to_hash
pg_conf_records[:records].each do |record|
  default['postgresql']['pg_hba'] << record
end

include_recipe "flashcards-cookbook::general"
include_recipe "postgresql::server"
include_recipe "database::postgresql"

# Prepare database connection
postgresql_connection_info = {
  host:     node["postgresql"]["config"]["listen_addresses"],
  port:     node["postgresql"]["config"]["port"],
  username: node["postgresql"]["username"]["postgres"],
  password: node["postgresql"]["password"]["postgres"]
}

postgresql_database "#{node['application']['name']}_#{node['application']['environment']}" do
  connection postgresql_connection_info
  action     :create
end

# Create application database user
postgresql_database_user node["application"]["database"]["username"] do
  connection postgresql_connection_info
  password node["application"]["database"]["password"]
  action :create
end

# Grant privileges to  application database user
postgresql_database_user node["application"]["database"]["username"] do
  connection    postgresql_connection_info
  database_name "#{node['application']['name']}_#{node['application']['environment']}"
  privileges    [:all]
  action        :grant
end
