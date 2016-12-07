#!/bin/sh

# Requirement: `jq` and `awscli` packages

if [ -z "$1" ]; then
    echo "ERROR: DOMAIN is required."
    exit 1
fi

if [ -z "$2" ]; then
    echo "ERROR: EMAIL is required."
    exit 1
fi

if [ -z "$3" ]; then
    echo "ERROR: S3 BUCKET URI is required. Ex: s3://cetificates"
    exit 1
fi

DOMAIN=$1
EMAIL=$2
S3_STORE=$3


ROLE=`curl -s http://169.254.169.254/latest/meta-data/iam/security-credentials/`
curl -s "http://169.254.169.254/latest/meta-data/iam/security-credentials/$ROLE" > /tmp/aws.keys
export AWS_ACCESS_KEY_ID=`cat /tmp/aws.keys | jq -j '.AccessKeyId'`
export AWS_SECRET_ACCESS_KEY=`cat /tmp/aws.keys | jq -j '.SecretAccessKey'`
export AWS_SESSION_TOKEN=`cat /tmp/aws.keys | jq -j '.Token'`
rm /tmp/aws.keys

if [ ! -d "$HOME/.acme.sh" ]; then
  # curl -s https://get.acme.sh | sh
  # https://github.com/Neilpang/acme.sh/issues/453
  git clone git@github.com:AntonTimiskov/acme.sh.git ~/.acme.sh
fi

echo "ACCOUNT_EMAIL=$EMAIL\n" >> ~/.acme.sh/account.conf

aws s3 sync $S3_STORE/$DOMAIN/ ~/.acme.sh/$DOMAIN/ 

~/.acme.sh/acme.sh --issue --dns dns_aws -d $DOMAIN # --debug

cp ~/.acme.sh/$DOMAIN/fullchain.cer ~/.acme.sh/$DOMAIN/fullchain.pem
cp ~/.acme.sh/$DOMAIN/$DOMAIN.key ~/.acme.sh/$DOMAIN/privkey.pem

aws s3 sync ~/.acme.sh/$DOMAIN/ $S3_STORE/$DOMAIN/
