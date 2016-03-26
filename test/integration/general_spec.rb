%w(postgresql-libs postgresql-devel openssl-devel libyaml-devel libffi-devel
   readline-devel zlib-devel gdbm-devel ncurses-devel
   policycoreutils policycoreutils-python).each do |package_name|
     describe package package_name do
       it { should be_installed }
     end
   end
