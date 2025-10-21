#!/bin/bash
# Update and install Apache
sudo apt-get update -y
sudo apt-get install -y apache2
sudo systemctl start apache2
sudo systemctl enable apache2

# Get instance metadata from the AWS metadata service
INSTANCE_ID=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)
HOSTNAME=$(curl -s http://169.254.169.254/latest/meta-data/hostname)
PUBLIC_IP=$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4)
INSTANCE_TYPE=$(curl -s http://169.254.169.254/latest/meta-data/instance-type)
AVAILABILITY_ZONE=$(curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone)

# Create a more detailed and styled HTML page
cat <<EOF | sudo tee /var/www/html/index.html
<!DOCTYPE html>
<html>
<head>
  <title>EC2 Instance Details</title>
  <style>
    body { font-family: Arial, sans-serif; background-color: #f4f4f4; color: #333; margin: 2em; }
    .container { background-color: #fff; padding: 20px; border-radius: 8px; box-shadow: 0 2px 4px rgba(0,0,0,0.1); }
    h1 { color: #d9534f; }
    p { line-height: 1.6; }
    strong { display: inline-block; width: 150px; }
  </style>
</head>
<body>
  <div class="container">
    <h1>Instance Details</h1>
    <p><strong>Instance ID:</strong> $INSTANCE_ID</p>
    <p><strong>Instance Type:</strong> $INSTANCE_TYPE</p>
    <p><strong>Availability Zone:</strong> $AVAILABILITY_ZONE</p>
    <p><strong>Hostname:</strong> $HOSTNAME</p>
    <p><strong>Public IP:</strong> $PUBLIC_IP</p>
  </div>
</body>
</html>
EOF
