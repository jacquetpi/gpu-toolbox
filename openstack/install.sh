#!/bin/bash
git clone https://opendev.org/openstack/devstack
cd devstack
cat > local.conf << 'EOF'
[[local|localrc]]
ADMIN_PASSWORD=secret
DATABASE_PASSWORD=$ADMIN_PASSWORD
RABBIT_PASSWORD=$ADMIN_PASSWORD
SERVICE_PASSWORD=$ADMIN_PASSWORD
EOF
sed -i 's/sudo /sudo-g5k /g' stack.sh # For Grid5000
sudo-g5k echo "Starting script"
export FORCE="yes" && ./stack.sh