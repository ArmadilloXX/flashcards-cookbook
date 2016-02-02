include_recipe 'java'
include_recipe 'chef-sugar'
include_recipe 'elasticsearch'

elasticsearch_user 'elasticsearch'
elasticsearch_install 'elasticsearch' do
  type node['elasticsearch']['install_type'].to_sym
end
elasticsearch_configure 'elasticsearch' do
      configuration ({
      'network.bind_host' => 0,
      'network.host' => '0.0.0.0',
      'script.inline' => 'sandbox',
      'script.aggs' => 'on',
      
    })
end
elasticsearch_service 'elasticsearch' do 
  action :start
end