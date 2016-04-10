########################################
# APPLICATION MAIN CONFIG
########################################
default["ruby_build"]["upgrade"]                      = true
default["application"]["name"]                        = "flashcards"
default["application"]["ruby_version"]                = "2.2.3"
default["application"]["app_server"]                  = "unicorn"
default["application"]["fqdn"]                        = "localhost"
default["application"]["environment"]                 = %w(production staging).include?(node.chef_environment) ? node.chef_environment : "development"
default["application"]["ssl"]                         = node["application"]["environment"] == "production"
default["application"]["database"]["username"]        = node["application"]["database"]["user"]
default["application"]["database"]["password"]        = node["application"]["database"]["password"]
default["application"]["database"]["host"]            = node["application"]["database"]["host"]
default["application"]["database"]["port"]            = node["application"]["database"]["port"]
default["application"]["database"]["name"]            = "#{default["application"]["name"]}_#{default["application"]["environment"]}"
# default["application"]["ssl_crt"]
# default["application"]["ssl_key"]
# default["application"]["public_key"]
# default["application"]["deploy_key"]

########################################
# APPLICATION ENVIRONMENT VARIABLES
########################################
default["application"]["env_vars"]                    = {}

########################################
# APPLICATION DEPLOYMENT CONFIG
########################################
default["application"]["deploy"]["force_assets"]      = true
default["application"]["deploy"]["user"]              = "deployer"
default["application"]["deploy"]["deploy_to"]         = "/var/www/#{node["application"]["name"]}"
default["application"]["deploy"]["repository"]        = "https://github.com/ArmadilloXX/flashcards.git"
default["application"]["deploy"]["revision"]          = "master"
default["nginx"]["default_site_enabled"]              = false

########################################
# POSTGRESQL
########################################
default["postgresql"]["enable_pgdg_yum"]              = true
default["postgresql"]["version"]                      = "9.4"
default["postgresql"]["dir"]                          = "/var/lib/pgsql/9.4/data"
default["postgresql"]["config"]["data_directory"]     = default["postgresql"]["dir"]
default["postgresql"]["client"]["packages"]           = ["postgresql94", "postgresql94-devel", "postgresql94-libs"]
default["postgresql"]["server"]["packages"]           = ["postgresql94-server"]
default["postgresql"]["server"]["service_name"]       = "postgresql-9.4"
default["postgresql"]["contrib"]["packages"]          = ["postgresql94-contrib"]
default["postgresql"]["setup_script"]                 = "postgresql94-setup"
default["postgresql"]["username"]["postgres"]         = "postgres" #TODO - Remove
default["postgresql"]["password"]["postgres"]         = "testpass" #TODO - Encrypt?
default["postgresql"]["config"]["port"]               = 5432
default["postgresql"]["config"]["listen_addresses"]   = "*"

########################################
# REDIS
########################################
default["redisio"]["version"]                         = "3.0.6"

########################################
# ELASTICSEARCH
########################################
default["java"]["jdk_version"]                        = node["elasticsearch"]["jdk_version"] || 8
default["elasticsearch"]["version"]                   = "2.1.1"
default["elasticsearch"]["download_url"]              = "https://download.elasticsearch.org/elasticsearch/release/org/elasticsearch/distribution/rpm/elasticsearch/2.2.1/elasticsearch-2.2.1.rpm"
default["elasticsearch"]["download_checksum"]         = "ddb5e1545e90b45e2b9495c35d5336a40fc63e09d8ac9cac73079888405df7f4"
default["elasticsearch"]["base_dir"]                  = "/opt"

########################################
# KIBANA
########################################
default["kibana"]["version"]                          = "4.4.2"
default["kibana"]["download_url"]                     = "https://download.elastic.co/kibana/kibana/kibana-4.4.2-linux-x64.tar.gz"
default["kibana"]["checksum"]                         = "ce0504d7a9440200b49851a64e010ddf8a8ed7b881135f6121d594ba1c0d6cfd"
default["kibana"]["dir"]                              = "/opt"
default["kibana"]["config"]["elasticsearch_url"]      = "http://127.0.0.1:9200"
default["kibana"]["config"]["elasticsearch.username"] = "kibana4-server"
default["kibana"]["config"]["elasticsearch.password"] = "password"
default["kibana"]["config"]["shield.encryptionKey"]   = "my_secret_key"
default["kibana"]["config"]["server.ssl.key"]         = "/opt/kibana/ssl/flashcards.key"
default["kibana"]["config"]["server.ssl.cert"]        = "/opt/kibana/ssl/flashcards.crt"
