def files_changed?(repository, path_to_previous_revision, files)
  `cd #{repository} && git log HEAD...$(cat #{path_to_previous_revision}) -- #{files} | wc -l`.to_i > 0
end

# def set_item_attributes_from_data_bags(data_bags, item)
#   data_bags.each do |data_bag|
#     attributes = get_data_bag_item(data_bag, item).to_hash
#     set_defaults(attributes, item)
#   end
# end

def set_default_attributes_from_data_bag(data_bag, items)
  items.each do |item|
    attributes = get_data_bag_item(data_bag, item).to_hash
    set_defaults(attributes, data_bag)
  end
end

def set_defaults(attributes, main_key)
  attributes.each do |key, value|
    node.default["#{main_key}"][key] =
      case value
      when Hash
        Chef::Mixin::DeepMerge.merge(node["#{main_key}"][key], value)
      else
        value
      end
  end
end

def get_data_bag_item(data_bag, item)
  case ChefVault::Item.data_bag_item_type(data_bag, item)
  when :normal, :encrypted
    data_bag_item(data_bag, item)
  when :vault
    chef_vault_item(data_bag, item)
  end
end

def set_additional_pg_hba_records
  item = data_bag_item("postgresql", "pg_hba_records").to_hash
  pg_hba = node['postgresql']['pg_hba'].dup
  item["records"].each { |record| pg_hba << record }
  node.default["postgresql"]["pg_hba"] = pg_hba
end

def database_users
  item = data_bag_item("postgresql", "database_users")
  item["db_users"]
end