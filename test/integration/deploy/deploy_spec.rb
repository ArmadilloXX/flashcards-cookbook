require_relative "../../helpers/application_helper.rb"

describe file("#{deploy_to}/current") do
  it_exists_and_owned_by "vagrant"
  it { should be_symlink }
end

describe file("#{deploy_to}/wrap-ssh4git.sh") do
  it_exists_and_owned_by "vagrant"
end

describe directory("#{deploy_to}/shared/vendor_bundle/ruby") do
  it_exists_and_owned_by "vagrant"
end

describe command("cd #{deploy_to}/current/ && bundle exec rake assets:precompile") do
  its("stdout") { should eq "" }
  its("exit_status") { should eq 0 }
end

%w(config log tmp system assets).each do |dir|
  describe directory("#{deploy_to}/shared/#{dir}") do
    it_exists_and_owned_by "vagrant"
  end
end

describe service("flashcards-sidekiq") do
  it { should be_running }
end

describe service("flashcards-unicorn") do
  it { should be_running }
end

describe service("nginx") do
  it { should be_running }
end
