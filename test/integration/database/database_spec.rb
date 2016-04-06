describe package "postgresql" do
  it { should be_installed }
end

describe service "postgresql-9.4" do
  it { should be_running }
end

describe command('psql -U postgres -l') do
  its("stdout") { should match "flashcards_development"}
end

describe command("psql -U postgres -c \'\\du\'") do
  its("stdout") { should match "vagrant" }
end