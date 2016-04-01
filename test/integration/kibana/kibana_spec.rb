require_relative "../../helpers/application_helper.rb"

control "SSL" do
  title "Test for correct installation of SSL key and certificate"

  describe directory "/opt/kibana-4.4.2/ssl" do
    it_exists_and_owned_by "kibana"
  end

  describe file "/opt/kibana-4.4.2/ssl/flashcards.crt" do
    it_exists_and_owned_by "kibana"
  end

  describe file "/opt/kibana-4.4.2/ssl/flashcards.key" do
    it_exists_and_owned_by "kibana"
  end
end

control "Kibana shield plugin" do
  title "Test for installation"

  describe directory "/opt/kibana-4.4.2/installedPlugins/shield" do
    it_exists_and_owned_by "kibana"
  end
end

control "Kibana systemd service" do
  title "Test for successful systemd service running"

  describe file "/etc/systemd/system/flashcards-kibana.service" do
    it_exists_and_owned_by "kibana"
  end

  describe service "flashcards-kibana" do
    it { should be_running }
  end
end
