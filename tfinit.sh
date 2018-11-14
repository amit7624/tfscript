#!/bin/bash -xe

export AWS_ACCESS_KEY_ID=${myAWSAccessKey}
export AWS_SECRET_ACCESS_KEY=${myAWSSecretKey}
export AWS_DEFAULT_REGION=us-east-1
 
PROJECT="$(basename `pwd`)"
BUCKET="myorgs-infra-state"

function terraform-install() {
  [[ -f ${HOME}/bin/terraform ]] && echo "`${HOME}/bin/terraform version` already installed at ${HOME}/bin/terraform" && return 0
  OS=$(uname -s)
  LATEST_VERSION=$(curl -sL https://releases.hashicorp.com/terraform/index.json | jq -r '.versions[].version' | sort -t. -k 1,1n -k 2,2n -k 3,3n -k 4,4n | egrep -v 'alpha|beta|rc' | tail -1)
  LATEST_URL="https://releases.hashicorp.com/terraform/${LATEST_VERSION}/terraform_${LATEST_VERSION}_${OS,,}_amd64.zip"
  curl ${LATEST_URL} > /tmp/terraform.zip
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

init() {
  if [ -d .terraform ]; then
    if [ -e .terraform/terraform.tfstate ]; then
      echo "Remote state already exist!"
      if [ -z $IGNORE_INIT ]; then
        exit 1
      fi
    fi
  fi
 
 terraform-install
 
  terraform remote config \
    -backend=s3 \
    -backend-config="bucket=${BUCKET}" \
    -backend-config="key=${PROJECT}/terraform.tfstate" \
    -backend-config="region=us-east-1"
 
}
 
while getopts "i" opt; do
  case "$opt" in
    i)
      IGNORE_INIT="true"
      ;;
  esac
done
 
shift $((OPTIND-1))
 
init
