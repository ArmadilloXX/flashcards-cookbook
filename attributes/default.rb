default['webapp']['ruby_version'] = '2.2.3'
default['webapp']['gems_to_install'] = ['bundler', 'rbenv-rehash', 'foreman']

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
default['postgresql']['password']['postgres'] = 'testpass' #TODO - Encrypt?
default['postgresql']['config']['port'] = 5432

# Redis
default['redisio']['version'] = '3.0.6'

# Java version for Elasticsearch
default['java']['jdk_version'] = 8

# Kibana
default['kibana']['version'] = '4.2.0'
default['kibana']['download_url'] = 'https://download.elastic.co/kibana/kibana/kibana-4.2.0-linux-x64.tar.gz'
default['kibana']['checksum'] = '67d586e43a35652adeb6780eaa785d3d785ce60cc74fbf3b6a9a53b753c8f985'
default['kibana']['config']['base_dir'] = '/opt/kibana'