#!/bin/bash
sudo yum update -y
export rdshost=${rdshost}
sudo amazon-linux-extras install -y php7.2
sudo yum install -y httpd php-mbstring php-xml
sudo usermod -a -G apache ec2-user
sudo usermod -a -G apache root
sudo systemctl start httpd
sudo systemctl enable httpd
sudo systemctl start php-fpm
sudo systemctl enable php-fpm
sudo mount -t nfs4 -o nfsvers=4.1 $(curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone).${aws_efs_file_system}.efs.${region}.amazonaws.com:/ /var/www/html
echo "$(curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone).${aws_efs_file_system}.efs.${region}.amazonaws.com:/ /var/www/html html defaults 0 0" >> /etc/fstab
cd /var/www/html
echo "Hello from $(hostname -f)" > /var/www/html/index.html
sudo wget https://www.phpmyadmin.net/downloads/phpMyAdmin-latest-all-languages.tar.gz
sudo mkdir phpMyAdmin && tar -xvzf phpMyAdmin-latest-all-languages.tar.gz -C phpMyAdmin --strip-components 1
sudo rm -rf phpMyAdmin-latest-all-languages.tar.gz
cd phpMyAdmin
sudo cp -a config.sample.inc.php config.inc.php
rdshost=${rdshost}
sudo sed -i 's/localhost/'$rdshost'/g' config.inc.php
sudo chown -R ec2-user:apache /var/www
sudo chmod 2775 /var/www && find /var/www -type d -exec sudo chmod 2775 {} \;
find /var/www -type f -exec sudo chmod 0664 {} \;
sudo systemctl restart httpd
sudo systemctl restart php-fpm
