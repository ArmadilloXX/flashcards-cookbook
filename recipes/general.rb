include_recipe "build-essential"

%w(openssl-devel libyaml-devel libffi-devel
   readline-devel zlib-devel gdbm-devel ncurses-devel
   policycoreutils policycoreutils-python).each do |package_name|
  package package_name do
    action :install
  end
end
