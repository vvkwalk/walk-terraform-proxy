/*EC2 variables can be used to store values such as the AMI ID, instance type, and VPC ID of an 
EC2 instance. These values in our Terraform code are used to create and configure EC2 instances. */

variable "ami" {
  description = "ami of ec2 instance"
  type        = string
  default     = "ami-0694d931cee176e7d"
}

# Launch Template and ASG Variables
variable "instance_type" {
  description = "launch template EC2 instance type"
  type        = string
  default     = "t2.micro"
}


#This user data variable indicates that the script configures Apache on a server.
variable "ec2_user_data" {
  description = "variable indicates that the script configures Apache on a server"
  type        = string
  default     = <<EOF
#!/bin/bash
# Install Apache on Ubuntu
# sudo apt update -y
# sudo apt install -y apache2
# sudo cat > /var/www/html/index.html << EOF
# <html>
# <head>
#   <title> Apache 2023 Terraform </title>
# </head>
# <body>
#   <p> Welcome to Walkover!!</p>
# </body>
# </html>


# Install nginx on Ubuntu
sudo apt update -y
sudo apt install nginx -y
sudo systemctl start nginx
sudo systemctl status nginx

#upload file from local to s3 #aws cli is mand.
#Dev: aws s3 cp /home/walkover/terraform_project/msg91-proxy-infra/autoscaling/<env.file> s3://irelandbucketvivek/dev/

#download file from s3
#aws s3 cp s3://irelandbucketvivek/dev/defaultdata.txt /var/www/html/


#php-fpm install
sudo add-apt-repository ppa:ondrej/php -y
sudo apt update
sudo apt install php8.1-fpm -y

#PHP Extension
sudo apt install php8.1-ctype php8.1-curl php8.1-dom php8.1-fileinfo php8.1-filter php8.1-hash php8.1-mbstring php8.1-openssl php8.1-pcre php8.1-pdo php8.1-session php8.1-tokenizer php8.1-xml -y
sudo apt install php8.1-fpm php8.1-ctype php8.1-curl php8.1-dom php8.1-fileinfo php8.1-filter php8.1-hash php8.1-mbstring php8.1-openssl php8.1-pcre php8.1-pdo php8.1-session php8.1-tokenizer php8.1-xml -y
sudo apt install php8.1-fpm php8.1-common php8.1-ctype php8.1-curl php8.1-dom php8.1-fileinfo php8.1-mbstring php8.1-pdo php8.1-xml -y

sudo touch /etc/nginx/conf.d/default.conf
sudo chmod 777 /etc/nginx/conf.d/default.conf
sudo cd /etc/nginx/conf.d

cat > default.conf << EOL 
server {
    # Listen on port 80
    # on both IPv4 and IPv6
    listen 80 default_server ipv6only=on;
    listen [::]:80 default_server ipv6only=on;

    # your domain or ip address
    server_name _;

    # document root
    root /var/www/html/public;

    # X-Frame-Options
    # config to don't allow the browser to render the page inside an frame or iframe
    # and avoid clickjacking http://en.wikipedia.org/wiki/Clickjacking
    # if you need to allow [i]frames, you can use SAMEORIGIN or even set an uri with ALLOW-FROM uri
    # https://developer.mozilla.org/en-US/docs/HTTP/X-Frame-Options
    add_header X-Frame-Options "SAMEORIGIN" always;
    
    # X-Content-Type-Options
    # when serving user-supplied content, include a X-Content-Type-Options: nosniff header along with the Content-Type: header,
    # to disable content-type sniffing on some browsers.
    # https://www.owasp.org/index.php/List_of_useful_HTTP_headers
    # currently suppoorted in IE > 8 http://blogs.msdn.com/b/ie/archive/2008/09/02/ie8-security-part-vi-beta-2-update.aspx
    # http://msdn.microsoft.com/en-us/library/ie/gg622941(v=vs.85).aspx
    # 'soon' on Firefox https://bugzilla.mozilla.org/show_bug.cgi?id=471020
    add_header X-Content-Type-Options "nosniff" always;
    
    # X-XSS-Protection
    # This header enables the Cross-site scripting (XSS) filter built into most recent web browsers.
    # It's usually enabled by default anyway, so the role of this header is to re-enable the filter for 
    # this particular website if it was disabled by the user.
    # https://www.owasp.org/index.php/List_of_useful_HTTP_headers
    add_header X-XSS-Protection "1; mode=block" always;

    # Priority file extensions, Add index.php to the list if you are using PHP
    index index.php;

    # removes trailing slashes (prevents SEO duplicate content issues)
	if (!-d $request_filename)
	{
		rewrite ^/(.+)/$ /$1 permanent;
	}

    #access_log  /var/log/nginx/host.access.log  main;

    # Define the document root of the server e.g /var/www/html
    location / {
        try_files $uri $uri/ /index.php?$query_string;
    }

    location = /favicon.ico {
        access_log off;
        log_not_found on;
    }
    location = /robots.txt  {
        access_log off;
        log_not_found on;
    }

    error_page 404 /index.php;
    # redirect server error pages to the static page /50x.html
    error_page 500 502 503 504 /index.php;

    # pass the PHP scripts to FastCGI server listening on 127.0.0.1:9000
    location ~ \.php$ {
        fastcgi_split_path_info ^(.+\.php)(/.+)$;
        fastcgi_pass php-fpm:9000;
        fastcgi_index index.php;
        include fastcgi_params;
        fastcgi_param SCRIPT_FILENAME $realpath_root$fastcgi_script_name;
        fastcgi_param PATH_INFO $fastcgi_path_info;
    }

    location ~ /\.(?!well-known).* {
        deny all;
    }

    # Deny access to hidden files (beginning with a period)
    location ~ /\. {
        deny all;
    }

    # deny access to .htaccess files,
    # if Apache's document root
    # deny access to .htaccess files
    location ~ /\.ht {
        deny  all;
    }
}
EOL

sudo systemctl restart nginx

EOF
}


/*This VPC can then be used to deploy resources that need to be accessible from the internet or from other resources in the VPC.
This variable defines the CIDR block for the VPC. The default value is 10.0.0.0/16.
*/

# VPC Variables
variable "vpc_cidr" {
  description = "VPC cidr block"
  type        = string
  default     = "10.10.0.0/16"
}

#These Public subnets are used for resources that need to be accessible from the internet
variable "public_subnet_cidr" {
  description = "Public Subnet cidr block"
  type        = list(string)
  default     = ["10.10.0.0/24", "10.10.2.0/24"]
}

#These Private subnets can be used to deploy resources that do not need to be accessible from the internet.
variable "private_subnet_cidr" {
  description = "Private Subnet cidr block"
  type        = list(string)
  default     = ["10.10.3.0/24", "10.10.4.0/24"]
}

#This is a Environement variable 
variable "environment" {
  description = "Environment name for deployment"
  type        = string
  default     = "terraformEnvironment"
}

# This is a Region Variable
variable "aws_region" {
  description = "AWS region name"
  type        = string
  default     = "eu-west-1"
}








#This user data variable indicates that the script configures Apache on a server.
# variable "ec2_user_data" {
#   description = "variable indicates that the script configures Apache on a server"
#   type        = string
#   default     = <<EOF
# #!/bin/bash
# sudo yum update –y
# sudo wget -O /etc/yum.repos.d/jenkins.repo \
#     https://pkg.jenkins.io/redhat-stable/jenkins.repo
# sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key
# sudo yum upgrade -y
# sudo amazon-linux-extras install java-openjdk11 -y
# sudo yum install jenkins -y
# sudo systemctl enable jenkins
# sudo systemctl start jenkins

# # Install Apache on Ubuntu
# sudo apt update -y
# sudo apt install -y apache2
# sudo cat > /var/www/html/index.html << EOF
# <html>
# <head>
#   <title> Apache 2023 Terraform </title>
# </head>
# <body>
#   <p> Welcome to Walkover!!</p>
# </body>
# </html>

# EOF
# }