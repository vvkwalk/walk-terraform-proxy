#!/bin/bash

# Function to SSH into a server and execute commands
function ssh_and_execute {
  local aws_region="$1"
  local server_name="$2"

  echo "Connecting to $server_name in region $aws_region"

  # Use AWS CLI to describe the instances and extract private IP addresses
  private_ips=$(aws ec2 describe-instances \
        --region "$aws_region" \
        --query "Reservations[].Instances[].PrivateIpAddress" \
        --filters "Name=tag:Name,Values=$server_name" \
        --output text)

  # Check if private IPs were found
  if [ -z "$private_ips" ]; then
    echo "No instances found for $server_name in region $aws_region"
  else
    # Loop through private IPs and SSH into each server
    for private_ip in $private_ips; do
      echo "Connecting to $server_name with private IP: $private_ip"

      # SSH into the server and execute commands
      ssh -i /home/ubuntu/id_rsa.pem ubuntu@$private_ip << EOF
        # Command 1
        echo "Running command 1 on $server_name" > text.txt
        # Command 2
        echo "Running command 2 on $server_name"
        # Command 3
        echo "Running command 3 for hostname"
        touch test.txt
        hostname -I
        aws s3 cp s3://irelandbucketvivek/dev/defaultdata.txt /etc/nginx/conf.d
EOF
    done
  fi
}

# Check if server names and regions were provided as arguments
if [ $# -lt 1 ]; then
  echo "Usage: $0 <region1:server_name1> <region2:server_name2> ..."
  exit 1
fi

# Loop through the provided arguments
for arg in "$@"; do
  IFS=':' read -ra parts <<< "$arg"
  aws_region="${parts[0]}"
  server_name="${parts[1]}"
  ssh_and_execute "$aws_region" "$server_name"
done

# both server have aws cli configuration

#Run this script from below command to perform action on private server
#./privateip.sh eu-west-1:terraformEnvironment-asg-ec2

#terraform created ec2 server file not upload directly so first we have to configure aws cli and "/etc/nginx/conf.d" path root permission then target server script working only other wise s3 file will not move on target server
#aws s3 cp s3://irelandbucketvivek/dev/defaultdata.txt /etc/nginx/conf.d       
#s3 static website hosting
#https://www.youtube.com/watch?v=YEIuuVKIy8U                                                                                                                             53,0-1        Bot
