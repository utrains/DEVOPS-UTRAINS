#!/bin/bash

#-----------------------------------------------------------------------------------------------------------------------#
# Date : 28 JAN 2025                                                                                                    #
# Description : This script file allows you to configure HASHICORP VAULT SERVER using Docker                            #
# Write By : Hermann90 for Utrains                                                                                      #
#-----------------------------------------------------------------------------------------------------------------------#

echo ">>>>>>>>>>>>>> VAULT CONFIGURATION <<<<<<<<<<<<<<<"
# VAULT_TOKEN=$1
# echo "The Vault token is $VAULT_TOKEN"
# docker pull hashicorp/vault

# docker volume create vault_config

# cat <<EOF > vault.hcl
# storage "file" {
#   path = "/vault/data"

# }
# listener "tcp" {
#   address     = "0.0.0.0:8200"
#   tls_disable = 1
  
# }
# ui = true
# EOF
# sudo mv vault.hcl /var/lib/docker/volumes/vault_config/_data/vault.hcl
# sudo chmod 777 /var/lib/docker/volumes/vault_config/_data/vault.hcl
#docker run --cap-add=IPC_LOCK -d --name=vault-server --restart=on-failure -e "VAULT_DEV_ROOT_TOKEN_ID=$VAULT_TOKEN" -p 8200:8200 hashicorp/vault 
#docker run -d --name=vault-server --cap-add=IPC_LOCK --restart=on-failure -p 8200:8200 -v vault_config:/vault/config -v vault_data:/vault/data hashicorp/vault server

# hashicorp vault server install on amazom linux 2


sudo yum install -y yum-utils shadow-utils
sudo yum-config-manager --add-repo https://rpm.releases.hashicorp.com/AmazonLinux/hashicorp.repo
sudo yum -y install vault
export VAULT_CONFIG=/etc/vault.d
export VAULT_BINARY=/usr/bin/vault

sudo tee /lib/systemd/system/vault.service <<EOF
[Unit]
Description="HashiCorp Vault"
Documentation="https://developer.hashicorp.com/vault/docs"
ConditionFileNotEmpty="${VAULT_CONFIG}/vault.hcl"

[Service]
User=vault
Group=vault
SecureBits=keep-caps
AmbientCapabilities=CAP_IPC_LOCK
CapabilityBoundingSet=CAP_SYSLOG CAP_IPC_LOCK
NoNewPrivileges=yes
ExecStart=${VAULT_BINARY} server -config=${VAULT_CONFIG}/vault.hcl
ExecReload=/bin/kill --signal HUP
KillMode=process
KillSignal=SIGINT

[Install]
WantedBy=multi-user.target
EOF

sudo chmod 644 /lib/systemd/system/vault.service
sudo systemctl daemon-reload
sudo systemctl enable vault
sudo systemctl start vault



# create vault config file
sudo systemctl stop vault  || echo "Vault is not running"
sudo rm -rf /etc/vault.d/vault.hcl || echo "config file not found"

sudo tee /etc/vault.d/vault.hcl <<EOF
storage "file" {
  path = "/opt/vault/data"
}
listener "tcp" {
  address     = "0.0.0.0:8200"
  tls_disable = 1
}
ui = true
EOF
# generate vault key
#systemctl stop vault 
rm -rf /opt/vault/data || echo ""
systemctl start vault
sleep 5
vault operator init --address http://127.0.0.1:8200 -key-shares=1 -key-threshold=1 > vaultkey.txt

