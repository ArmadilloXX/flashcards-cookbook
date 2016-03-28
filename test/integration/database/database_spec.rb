describe package "postgresql" do
  it { should be_installed }
end

describe service "postgresql-9.4" do
  it { should be_running }
end