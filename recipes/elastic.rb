include_recipe 'java'
include_recipe 'chef-sugar'
include_recipe 'elasticsearch'

elasticsearch_user 'elasticsearch'
elasticsearch_install 'elasticsearch' do
  type node['elasticsearch']['install_type'].to_sym # since TK can't symbol.
end
elasticsearch_configure 'elasticsearch' do
      configuration ({
      'network.bind_host' => 0,
      'network.host' => '0.0.0.0'
    })
end
elasticsearch_service 'elasticsearch' do 
  action :start
end