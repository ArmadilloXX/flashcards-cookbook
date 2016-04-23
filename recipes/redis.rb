if node["application"]['override_config_from_data_bag']
  include_recipe "chef-vault"
  override_settings_from_data_bag('flashcards', 'flashcards_config')
  override_settings_from_data_bag('flashcards', 'flashcards_secrets')
end

include_recipe "flashcards-cookbook::general"
include_recipe "redisio"
include_recipe "redisio::enable"
