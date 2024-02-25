#! /bin/bash
sudo yum update -y
sudo yum install -y httpd
sudo systemctl enable httpd.service
sudo systemctl start httpd.service
echo "<h1>Welcome to terraform!</h1>" | sudo tee /var/www/html/index.html