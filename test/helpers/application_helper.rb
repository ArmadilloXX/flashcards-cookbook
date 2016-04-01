def deploy_to
  "/var/www/flashcards"
end

def it_exists_and_owned_by(owner)
  it { should exist }
  its("owner") { should eq owner }
  its("group") { should eq owner }
end