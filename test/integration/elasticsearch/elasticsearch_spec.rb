describe package "elasticsearch" do
  it { should be_installed }
end

describe directory "/usr/share/elasticsearch/plugins/license" do
  it { should exist }
end

describe directory "/usr/share/elasticsearch/plugins/shield" do
  it { should exist }
end

%w(es_admin kibana4-server testuser).each do |user|
  describe command("/usr/share/elasticsearch/bin/shield/esusers list | grep #{user}") do
    its("stdout") { should match user }
  end
end

describe service "elasticsearch" do
  it { should be_running }
end

describe command("curl localhost:9200") do
  its("stdout") { should match 'missing authentication token' }
end

describe command("curl -u testuser:testpass localhost:9200") do
  its("stdout") { should match 'You Know, for Search' }
end