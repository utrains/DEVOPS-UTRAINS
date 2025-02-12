#!/bin/bash

#-----------------------------------------------------------------------------------------------------------------------#
# Date : 28 JAN 2025                                                                                                    #
# Description : This script file allows you to configure HASHICORP VAULT SERVER using Docker                            #
# Write By : Hermann90 for Utrains                                                                                      #
#-----------------------------------------------------------------------------------------------------------------------#

echo ">>>>>>>>>>>>>> VAULT CONFIGURATION <<<<<<<<<<<<<<<"
VAULT_TOKEN=$1
echo "The Vault token is $VAULT_TOKEN"
docker pull hashicorp/vault
docker run --cap-add=IPC_LOCK -d --name=vault-server --restart=on-failure -e "VAULT_DEV_ROOT_TOKEN_ID=$VAULT_TOKEN" -p 8200:8200 hashicorp/vault

echo "The Vault token is $VAULT_TOKEN"
