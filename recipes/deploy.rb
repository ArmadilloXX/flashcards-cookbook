include_recipe "flashcards-cookbook::application"

symlinks = {".env" => ".env"}

app_server = node["application"]["app_server"]
symlinks.merge!("config/#{app_server}.rb" => "config/#{app_server}.rb")

deploy node['application']["deploy"]["deploy_to"] do
  repo node['application']["deploy"]["repository"]
  branch node['application']["deploy"]["revision"]
  migrate true
  migration_command "bundle exec rake db:migrate && bundle exec rake db:seed"
  environment 'RAILS_ENV' => node['application']['environment']

  ssh_wrapper "#{node['application']["deploy"]["deploy_to"]}/wrap-ssh4git.sh"

  symlink_before_migrate symlinks

  symlinks(
    "config" => "config",
    "log"    => "log",
    "tmp"    => "tmp",
    "system" => "public/system",
    "assets" => "public/assets"
  )

  user node['application']["deploy"]["user"]
  group node['application']["deploy"]["user"]

  before_migrate do
    execute "install_gems" do
      command "bundle install --deployment --path #{node['application']["deploy"]["deploy_to"]}/shared/vendor_bundle"
      cwd release_path
      user node['application']["deploy"]["user"]
      group node['application']["deploy"]["user"]
    end
  end

  before_restart do
    execute "precompile_assets" do
      command "bundle exec rake assets:precompile && rm -rf #{release_path}/tmp/cache"
      cwd release_path
      user node['application']["deploy"]["user"]
      group node['application']["deploy"]["user"]
      environment "RAILS_ENV" => node['application']['environment']
      only_if {
        node['application']["deploy"]["force_assets"] || files_changed?(release_path, "#{node['application']["deploy"]["deploy_to"]}/shared/previous_revision", "app/assets lib/assets vendor/assets config/environments/#{node['application']['environment']}.rb")
      }
    end
  end

  after_restart do
    # execute "update_crontab" do
    #   command "bundle exec whenever --update-crontab '#{node['application']['name']}_#{node['application']['environment']}'"
    #   cwd release_path
    #   environment "RAILS_ENV" => node['application']['environment']
    # end

    execute "save_revision" do
      command "git rev-parse HEAD > #{node['application']["deploy"]["deploy_to"]}/shared/previous_revision"
      cwd release_path
    end
  end

  notifies :restart, "service[#{node['application']["name"]}-#{node['application']['app_server']}]"
  notifies :restart, "service[#{node['application']["name"]}-sidekiq]"
  notifies :restart, "service[nginx]"

  action :deploy
end
