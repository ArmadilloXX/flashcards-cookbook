require_relative "../../helpers/application_helper.rb"

describe file("#{deploy_to}/current") do
  it { should exist }
  it { should be_symlink }
end

describe file("#{deploy_to}/wrap-ssh4git.sh") do
  it { should exist }
end

describe directory("#{deploy_to}/shared/vendor_bundle/ruby") do
  it { should exist }
end

describe command("cd #{deploy_to}/current/ && bundle exec rake assets:precompile") do
  its("stdout") { should eq "" }
  its("exit_status") { should eq 0 }
end

%w(config log tmp system assets).each do |dir|
  describe directory("#{deploy_to}/shared/#{dir}") do
    it { should exist }
  end
end

describe service("flashcards-sidekiq") do
  it { should be_running }
end

describe service("nginx") do
  it { should be_running }
end

# describe command("curl localhost:3000") do
#   its("stdout") { should match "Welcome" }
# end
