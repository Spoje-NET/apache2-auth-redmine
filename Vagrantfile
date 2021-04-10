# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  # Debian 9 configuration
  config.vm.box = "debian/stretch64"

  config.vm.network "forwarded_port", guest: 80, host: 8090

  config.vm.provision "shell", inline: <<-SHELL
    export DEBIAN_FRONTEND=noninteractive
    echo "deb [trusted=yes] file:///vagrant/deb ./" > /etc/apt/sources.list.d/local.list

    apt-get update
    apt-get install -y mysql-server curl mc htop screen ccze links
    apt-get install -y apache2 redmine-mysql libapache2-mod-passenger
    cp /vagrant/test/redmineinvagrant.conf /etc/apache2/conf-available/redmine.conf
    cp -f /vagrant/test/database.yml /etc/redmine/default/database.yml
    cp -f /vagrant/test/index.html   /var/www/html/index.html
    echo "CREATE DATABASE redmine CHARACTER SET utf8mb3 COLLATE = utf8mb3_unicode_ci;" | mysql
    echo "grant all on redmine.* to 'redmine'@'localhost' identified by 'redmine';" | mysql
    cd /usr/share/redmine/
    RAILS_ENV=production bundle exec rake db:migrate
    bundle exec rake redmine:plugins:migrate RAILS_ENV=production
    cd
    a2enconf redmine
    chown www-data:www-data /usr/share/redmine -R
    apt-get install -y apache2-auth-redmine
    apt-get install -y xinit xfce4-session firefox-esr
    systemctl reload apache2

    links -dump http://localhost/redmine/


  SHELL
end
