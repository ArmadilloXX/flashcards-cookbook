def files_changed?(repository, path_to_previous_revision, files)
  `cd #{repository} && git log HEAD...$(cat #{path_to_previous_revision}) -- #{files} | wc -l`.to_i > 0
end

def set_attrs_from_data_bag(databag, item)
  attributes = get_data_bag_item(databag, item)
  attributes.to_hash.each do |key, value|
    node.default["#{item}"][key] =
      case value
      when Hash
        Chef::Mixin::DeepMerge.merge(node["#{item}"][key], value)
      else
        value
      end
  end
end

def get_data_bag_item(databag, item)
  case ChefVault::Item.data_bag_item_type("#{databag}", "#{item}")
  when :normal
    data_bag_item(databag, item)
  when :encrypted
    data_bag_item(databag, item)
  when :vault
    chef_vault_item("credentials", "#{item}")
  end
end