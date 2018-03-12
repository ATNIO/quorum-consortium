# docker-compose-quorum
Docker compose 3 quorum nodes
## Installation
~~~shell
git clone https://github.com/pplam/docker-compose-quorum.git
cd docker-compose-quorum
docker build -t quorum .
~~~
## Usage
~~~shell
./setup.sh
docker-compose up -d
~~~
Then `geth attach http://0.0.0.0:22001` and copy code in `contract_pri.js`, paste it to the console to create a private contract.
