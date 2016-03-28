include_recipe "chef-vault"
data_bag_items = %w(config credentials)
set_default_attributes_from_data_bag("postgresql", data_bag_items)
set_additional_pg_hba_records

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

# Create database users and grants privileges to them
database_users.each do |user|
  postgresql_database_user user["username"] do
    connection postgresql_connection_info
    password   user["password"]
    action     :create
  end

  postgresql_database_user user["username"] do
    connection    postgresql_connection_info
    database_name user["database_name"]
    privileges    user["privileges"].map { |p| p.to_sym }
    action        :grant
  end
end
