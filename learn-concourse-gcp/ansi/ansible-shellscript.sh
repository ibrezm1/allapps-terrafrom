# Remove anything which may clash with Docker
apt-get remove -y docker docker-engine docker.io containerd runc
apt-get update

# Add dependant libraries
apt-get install -y apt-transport-https ca-certificates curl software-properties-common wget htop


apt update
apt install --yes apt-transport-https ca-certificates curl gnupg2 software-properties-common
curl -fsSL https://download.docker.com/linux/debian/gpg | sudo apt-key add -
add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/debian $(lsb_release -cs) stable"
wget -q -O - https://packages.cloudfoundry.org/debian/cli.cloudfoundry.org.key | sudo apt-key add -
echo "deb https://packages.cloudfoundry.org/debian stable main" | sudo tee /etc/apt/sources.list.d/cloudfoundry-cli.list

sudo apt-get update
apt update
apt install --yes docker-ce
sudo apt-get install cf-cli

# Download Docker Compose, move it to usr bin and make executable
curl -L "https://github.com/docker/compose/releases/download/1.23.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
docker-compose --version



# Download the Concourse Compose yaml and rename to a file which Compose with recognize
cd /tmp
wget -O docker-compose.yml https://gitlab.com/snippets/1864804/raw

# Sets the external URL to be the IP address of the machine
ipaddr=$(wget -O - -q https://icanhazip.com/)
sed "s|EXTERNAL_URL=|EXTERNAL_URL=http://$ipaddr:8080|g" docker-compose.yml -i

# Start the containers and show the state
docker-compose up -d
docker ps
echo -e "\n"
cat docker-compose.yml |grep EXTERNAL_URL | sed -e 's/^[[:space:]]*- //'
echo "Waiting 30 seconds for Concourse to start"
sleep 30 # wait for the container to start. Can tune down if needed.

# Download and install the fly cli
wget -O /tmp/fly "http://$ipaddr:8080/api/v1/cli?arch=amd64&platform=linux"
mkdir -p /usr/local/bin
mv /tmp/fly /usr/local/bin
chmod 0755 /usr/local/bin/fly
git clone https://github.com/starkandwayne/concourse-tutorial.git

git clone https://github.com/ibrezm1/cf-HelloWorld.git
sudo chown -R Ibrez ./cf-HelloWorld/
sudo chown -R Ibrez ./concourse-tutorial/


# Fly login, create target main and display targets
exec sudo -u Ibrez /bin/sh - << eof
ipaddr=$(wget -O - -q https://icanhazip.com/)
fly --target main login --concourse-url http://$ipaddr:8080 -u test -p test
fly --target tutorial login --concourse-url http://$ipaddr:8080 -u test -p test
fly targets
touch completed.txt
eof

