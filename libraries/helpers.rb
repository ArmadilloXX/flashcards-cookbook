def files_changed?(repository, path_to_previous_revision, files)
  cmd = "cd #{repository} && git log HEAD...$(cat #{path_to_previous_revision}) -- #{files} | wc -l"
  Mixlib::ShellOut.new(cmd).run_command.to_i > 0
end

def override_settings_from_data_bag(data_bag, item)
  config = get_data_bag_item(data_bag, item)
  config.to_hash.each do |key, value|
    node.default[key] =
      case value
      when Hash
         Chef::Mixin::DeepMerge.merge(node[key].dup, value)
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
  new_records = node["postgresql"]["additional_hba_records"]
  pg_hba = node['postgresql']['pg_hba'].dup
  new_records.each { |record| pg_hba << record }
  node.default["postgresql"]["pg_hba"] = pg_hba
end
