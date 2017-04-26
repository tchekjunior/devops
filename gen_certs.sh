#!/bin/bash

CERT_PATH=$PWD/certs
CERT_PASS="yanfashi-2017"
CERT_TYPE="gitlab"
CERT_DAYS=365

C="CN"
ST="Guizhou"
L="Guiyang"
O="China mobile"
OU="Guizhou Ltd."

usage() {
  echo -e "USAGE:\t$0 [-t <gitlab|registry|docker>] <-h DOMIAN_NAME> [-d DAYS]"
  echo -e "example:\n\t$0 -t gitlab -h gitlab.gz.cmcc -d 3650\n"
}

gitlab_cert() {
  echo "STEP 1: Create the server private key"
  openssl genrsa -out $CERT_PATH/gitlab.key 2048
  echo "STEP 2: Create the certificate signing request (CSR)"
  openssl req -new -key $CERT_PATH/gitlab.key -out $CERT_PATH/gitlab.csr -subj "/C=$C/ST=$ST/L=$L/O=$O/OU=$OU/CN=$DOMAIN_NAME"
  echo 'STEP 3: Sign the certificate using the private key and CSR'
  openssl x509 -req -days $CERT_DAYS -in $CERT_PATH/gitlab.csr -signkey $CERT_PATH/gitlab.key -out $CERT_PATH/gitlab.crt
  #echo 'STEP 4: Strengthening the server security'
  openssl dhparam -out $CERT_PATH/dhparam.pem 2048
  rm -f $CERT_PATH/gitlab.csr
}

registry_cert(){
  echo 'STEP 1: Create the server private key with nginx'
  openssl genrsa -out $CERT_PATH/registry.key 2048
  echo 'STEP 2: Create the certificate signing request (CSR)'
  openssl req -new -key $CERT_PATH/registry.key -out $CERT_PATH/registry.csr -subj "/C=$C/ST=$ST/L=$L/O=$O/OU=$OU/CN=$DOMAIN_NAME"
  echo 'STEP 3: Sign the certificate using the private key and CSR'
  openssl x509 -req -days $CERT_DAYS -in $CERT_PATH/registry.csr -signkey $CERT_PATH/registry.key -out $CERT_PATH/registry.crt
  rm -f $CERT_PATH/registry.csr
  echo 'STEP 4: Create the server private key with registry'
  openssl req -x509 -days $CERT_DAYS -subj "/C=$C/ST=$ST/L=$L/O=$O/OU=$OU/CN=$DOMAIN_NAME" -nodes -newkey rsa:2048 -keyout $CERT_PATH/registry-server.key -out $CERT_PATH/registry-server.crt
}

docker_cert(){
   if [ ! -f "$CERT_PATH/gitlab.crt" ]; then
      echo "gitlab.crt not be found. Please create the certificate using eg.\"$0 -t gitlab -h gitlab.gz.cmcc -d 365\" and try again."
      exit 1
   fi
   
   if [ ! -f "$CERT_PATH/registry.crt" ]; then
      echo "registry.crt not be found. Please create the certificate using eg.\"$0 -t registry -h hub.gz.cmcc -d 365\" and try again."
      exit 1
   fi
   
   if [ ! -d "/etc/docker/certs.d/$DOMAIN_NAME" ]; then
      sudo mkdir -p /etc/docker/certs.d/$DOMAIN_NAME
   fi

   sudo sh -c "cat $CERT_PATH/gitlab.crt $CERT_PATH/registry.crt > /etc/docker/certs.d/$DOMAIN_NAME/ca.crt" 
}

if [ $# -lt 1 ]; then
   usage
   exit 1
fi

if [ ! -d "$CERT_PATH" ]; then
  mkdir -p $CERT_PATH
fi

while getopts "t:h:d:" arg
do
    case $arg in
       t)
  	   CERT_TYPE=$OPTARG
	   ;;
       h)
	   DOMAIN_NAME=$OPTARG
           ;;
       d)
           CERT_DAYS=$OPTARG
           ;;
       ?)
           usage
           exit 1
           ;;
    esac
done

if [ "gitlab" == "$CERT_TYPE" ]; then
  gitlab_cert  
elif [ "registry" == "$CERT_TYPE" ]; then
  registry_cert
elif [ "docker" == "$CERT_TYPE" ]; then
  docker_cert
else
   usage
   exit 1
fi
