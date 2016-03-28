control "SSL" do
  title "Test for correct installation of SSL key and certificate"

  describe directory "/opt/kibana-4.4.2/ssl" do
    it { should exist }
    its("owner") { should eq "kibana" }
  end

  describe file "/opt/kibana-4.4.2/ssl/flashcards.crt" do
    it { should exist }
    its("owner") { should eq "kibana" }
  end

  describe file "/opt/kibana-4.4.2/ssl/flashcards.key" do
    it { should exist }
    its("owner") { should eq "kibana" }
  end
end

control "Kibana shield plugin" do
  title "Test for installation"

  describe directory "/opt/kibana-4.4.2/installedPlugins/shield" do
    it { should exist }
    its("owner") { should eq "kibana" }
  end
end

control "Kibana systemd service" do
  title "Test for successful systemd service running"

  describe file "/etc/systemd/system/flashcards-kibana.service" do
    it { should exist }
    its("owner") { should eq "kibana" }
  end

  describe service "flashcards-kibana" do
    it { should be_running }
  end
end
