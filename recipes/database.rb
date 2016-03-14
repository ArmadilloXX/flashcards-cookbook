include_recipe "chef-vault"
data_bags = %w(general config credentials)
set_item_attributes_from_data_bags(data_bags, "postgresql")
set_pg_conf_records

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

db_users.each do |user|
# Create application database user
  postgresql_database_user user["name"] do
    connection postgresql_connection_info
    password user["password"]
    action :create
  end

  # Grant privileges to  application database user
  postgresql_database_user user[:name] do
    connection    postgresql_connection_info
    database_name user[:database_name]
    # database_name "#{node['application']['name']}_#{node['application']['environment']}"
    privileges    user[:privileges].map { |p| p.to_sym }
    action        :grant
  end
end
