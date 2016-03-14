def files_changed?(repository, path_to_previous_revision, files)
  `cd #{repository} && git log HEAD...$(cat #{path_to_previous_revision}) -- #{files} | wc -l`.to_i > 0
end

def set_item_attributes_from_data_bags(data_bags, item)
  data_bags.each do |data_bag|
    attributes = get_data_bag_item(data_bag, item).to_hash
    set_defaults(attributes, item)
  end
end

def set_defaults(attributes, item)
  attributes.each do |key, value|
    node.default["#{item}"][key] =
      case value
      when Hash
        Chef::Mixin::DeepMerge.merge(node["#{item}"][key], value)
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