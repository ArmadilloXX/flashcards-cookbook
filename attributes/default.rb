default["application"]["name"] = "flashcards"
default["application"]["ruby_version"] = "2.2.3"
default["application"]["app_server"] = "unicorn"
default["application"]["fqdn"] = "localhost"
default['application']['env_vars'] = {}
default["application"]["environment"] = %w(production staging).include?(node.chef_environment) ? node.chef_environment : "development"
default["application"]["deploy"]["force_assets"] = true
# default['application']['ssl_crt']
# default['application']['ssl_key']
# default['application']['public_key']
# default['application']['deploy_key']
# default["application"]["ssl"] = node["application"]["environment"] == "production"
default["application"]["deploy"]["user"] = "deployer"
default["application"]["deploy"]["deploy_to"] = "/var/www/#{node['application']['name']}"
default["application"]["deploy"]["repository"] = "https://github.com/ArmadilloXX/flashcards.git"
default["application"]["deploy"]["revision"] = "master"



default["application"]["database"]["username"] = node["application"]["database"]["user"]
default["application"]["database"]["password"] = node["application"]["database"]["password"]
default["application"]["database"]["host"] = node["application"]["database"]["host"]
default["application"]["database"]["port"] = node["application"]["database"]["port"]
default["application"]["database"]["name"] = "#{default['application']['name']}_#{default['application']['environment']}"

# default["app-rails"]["deploy"]["force_assets"] = true



# default["nginx"]["default_site_enabled"]       = false

# build-essential
# default['build-essential']['compile_time'] = true

# Postgresql
# default['postgresql']['version'] = "9.4"
# default['postgresql']['enable_pgdg_yum'] = true
# default['postgresql']['dir'] = "/var/lib/pgsql/9.4/data"
# default['postgresql']['config']['data_directory'] = default['postgresql']['dir']
# default['postgresql']['client']['packages'] = ["postgresql94", "postgresql94-devel"]
# default['postgresql']['server']['packages'] = ["postgresql94-server"]
# default['postgresql']['server']['service_name'] = "postgresql-9.4"
# default['postgresql']['contrib']['packages'] = ["postgresql94-contrib"]
# default['postgresql']['setup_script'] = "postgresql94-setup"
# default['postgresql']['username']['postgres'] = 'postgres'
# default['postgresql']['password']['postgres'] = 'testpass' #TODO - Encrypt?
# default['postgresql']['config']['port'] = 5432
# default['postgresql']['config']['listen_addresses'] = "*"
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
