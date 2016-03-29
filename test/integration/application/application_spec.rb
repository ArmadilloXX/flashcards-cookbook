describe command("/opt/rbenv/shims/ruby") do
  its("stdout") { should match "2.2.3" }
 end

describe file("/opt/rbenv/shims/gem") do
  it { should exist }
end

describe user("vagrant") do
  it { should exist }
  its("group") { should eq "vagrant" }
  its("home") { should eq "/home/vagrant" }
end

describe file("/etc/nginx/sites-available/flashcards") do
  it { should exist }
end

describe file("/etc/nginx/sites-available/flashcards") do
  it { should exist }
end

describe file("/etc/systemd/system/flashcards-sidekiq.service") do
  it { should exist }
end

describe file("/home/vagrant/.ssh/id_rsa.pub") do
  it { should exist }
  its("owner") { should eq "vagrant" }
end

describe file("/home/vagrant/.ssh/id_rsa") do
  it { should exist }
  its("owner") { should eq "vagrant" }
end

deploy_to = "/var/www/flashcards"

describe directory(deploy_to) do
  it { should exist }
  its("owner") { should eq "vagrant" }
end

describe directory("#{deploy_to}/shared") do
  it { should exist }
  its("owner") { should eq "vagrant" }
  its("group") { should eq "vagrant" }
end

describe file("#{deploy_to}/shared/.env") do
  it { should exist }
  its("owner") { should eq "vagrant" }
  its("group") { should eq "vagrant" }
  its("content") { should match "DATABASE_HOST=\"127.0.0.1\"" }
  its("content") { should match "DATABASE_PASSWORD=\"vagrant\"" }
  its("content") { should match "DATABASE_PORT=\"5432\"" }
  its("content") { should match "DATABASE_USERNAME=\"vagrant\"" }
end

%w(config system vendor_bundle log pids assets tmp).each do |dir|
  describe directory("#{deploy_to}/shared/#{dir}") do
    it { should exist }
    its("owner") { should eq "vagrant" }
    its("group") { should eq "vagrant" }
  end
end
