#!/bin/bash -xe

export AWS_ACCESS_KEY_ID=${bamboo_myAWSAccessKey}
export AWS_SECRET_ACCESS_KEY=${bamboo_myAWSSecretKey}
export AWS_DEFAULT_REGION=us-east-1
echo AWS_ACCESS_KEY_ID
echo AWS_SECRET_ACCESS_KEY


PROJECT="$(basename `pwd`)"
echo PROJECT

BUCKET="myorgs-infra-state"
echo BUCKET

function terraform-install() {
  curl https://releases.hashicorp.com/terraform/0.11.10/terraform_0.11.10_darwin_amd64.zip > /tmp/terraform.zip
  echo ${HOME}/bin

  mkdir -p ${HOME}/bin
  (cd ${HOME}/bin && unzip /tmp/terraform.zip)
  if [[ -z $(grep 'export PATH=${HOME}/bin:${PATH}' ~/.bashrc 2>/dev/null) ]]; then
  	echo 'export PATH=${HOME}/bin:${PATH}' >> ~/.bashrc
  fi
  
  echo "Installed: `${HOME}/bin/terraform version`"
  
  cat - << EOF 
 
Run the following to reload your PATH with terraform:
  source ~/.bashrc
EOF
}

terraform-install
