# devops
DevOps of docker
#### Install docker-engine
sudo sh -c "curl -fsSL https://get.docker.com/ | sh"  
sudo docker info
#### Install docker-compose
sudo sh -c "curl -L https://github.com/docker/compose/releases/download/1.13.0-rc1/docker-compose-\`uname -s\`-\`uname -m\`>/usr/local/bin/docker-compose"
sudo chmod +x /usr/local/bin/docker-compose
docker-compose --version
#### Create a self-signed ssl certificate
./gen_certs.sh -h gitlab.dev.gz.cmcc -d 3650  
./gen_certs.sh -t registry -h hub.dev.gz.cmcc -d 3650
#### Create docker client tls certificate
./gen_certs.sh -t docker -h hub.dev.gz.cmcc  
#### Run docker-compose
docker-compose up -d
