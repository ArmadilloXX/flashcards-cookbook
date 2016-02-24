default["application"]['ruby_version'] = '2.2.3'
default["application"]['gems_to_install'] = ['bundler', 'rbenv-rehash']
# default["app-rails"]["app_server"]             = "passenger"

# default["app-rails"]["environment"]            = %w(production staging).include?(node.chef_environment) ? node.chef_environment : "development"
# default["app-rails"]["ruby_version"]           = "2.2.3"

# default["app-rails"]["deploy"]["force_assets"] = true
# default["app-rails"]["deploy"]["revision"]     = "master"
# default["app-rails"]["deploy"]["user"]         = "deployer"
# default["app-rails"]["deploy"]["deploy_to"]    = "/var/www/#{node["app-rails"]["name"]}"

# default["app-rails"]["database"]["name"]       = "#{node["app-rails"]["name"]}_#{node["app-rails"]["environment"]}"
# default["app-rails"]["database"]["user"]       = "postgres"
# default["app-rails"]["database"]["host"]       = "localhost"
# default["app-rails"]["database"]["port"]       = 5432

# default["app-rails"]["ssl"]                    = node["app-rails"]["environment"] == "production"

# default["nginx"]["default_site_enabled"]       = false

# build-essential
default['build-essential']['compile_time'] = true

# Postgresql
default['postgresql']['version'] = "9.4"
default['postgresql']['enable_pgdg_yum'] = true
default['postgresql']['dir'] = "/var/lib/pgsql/9.4/data"
default['postgresql']['config']['data_directory'] = default['postgresql']['dir']
default['postgresql']['client']['packages'] = ["postgresql94", "postgresql94-devel"]
default['postgresql']['server']['packages'] = ["postgresql94-server"]
default['postgresql']['server']['service_name'] = "postgresql-9.4"
default['postgresql']['contrib']['packages'] = ["postgresql94-contrib"]
default['postgresql']['setup_script'] = "postgresql94-setup"
default['postgresql']['username']['postgres'] = 'postgres'
default['postgresql']['password']['postgres'] = 'testpass' #TODO - Encrypt?
default['postgresql']['config']['port'] = 5432
default['postgresql']['config']['listen_addresses'] = "*"
pg_conf = default['postgresql']['pg_hba'] << {
  type: "host",
  db: "all",
  user: "vagrant",
  addr: "192.168.50.0/24", #TODO Add correct mask
  method: "md5"
}
default['postgresql']['pg_hba'] = pg_conf

# Redis
default['redisio']['version'] = '3.0.6'

# Java version for Elasticsearch
default['java']['jdk_version'] = 8

# Elasticsearch
default['elasticsearch']['version'] = '2.1.1'

# Kibana
default['kibana']['download_url'] = 'https://download.elastic.co/kibana/kibana/kibana-4.3.1-linux-x64.tar.gz'
default['kibana']['checksum'] = 'c6a91921a0055714fd24fb94a70b7057f43492da6bd8c4f2f1acbf0964bf09b9'
default['kibana']['version'] = '4.3.1'
default['kibana']['config']['base_dir'] = '/opt/kibana'
default['kibana']['access']['username'] = 'testuser'
default['kibana']['access']['password'] = 'testpass' #TODO - Encrypt?