make all
export TFHE_EXECUTOR_CONTRACT_ADDRESS=0x5d
export FHEVM_GO_KEYS_DIR=~/.fhekeys

sudo rm -rf data

mkdir data/
mkdir data/node1
mkdir data/node2
mkdir data/miner

echo "password" > password.txt
./build/bin/geth --datadir data/node1/ account new --password password.txt
./build/bin/geth --datadir data/node2/ account new --password password.txt
./build/bin/geth --datadir data/miner/ account new --password password.txt

touch genesis.json
# todo: edit genesis.json : replace alloc address with the address created above

./build/bin/geth --datadir data/node1/ init genesis.json
./build/bin/geth --datadir data/node2/ init genesis.json
./build/bin/geth --datadir data/miner/ init genesis.json

./build/bin/bootnode -genkey boot.key
./build/bin/bootnode -nodekey boot.key -addr :30300
#-addr=30301 -verbosity=5 > bootnode.log 2>&1 &

#Bootstrap node
export TFHE_EXECUTOR_CONTRACT_ADDRESS=0x5d
export FHEVM_GO_KEYS_DIR=./fhekeys
export NODE_KEY="enode://8c1d69db085bb50a67bdcd40e7724f0b7726b6d28dc31628bc58ea52fc8e13f4a160fce250a94babfb8b2d2efc4edc00adc94023991877c857d6e0b34e91a5db@127.0.0.1:0?discport=30300"

./build/bin/geth --datadir data/node1 --ipcdisable --port 30301 --authrpc.port 8551 --bootnodes "$NODE_KEY" --networkid 666 --http --http.addr 'localhost' --http.port 8001 --http.api 'admin,debug,eth,miner,net,personal,txpool,web3' --ws --ws.addr 'localhost' --ws.port 8202 --ws.api 'admin,debug,eth,miner,net,personal,txpool,web3' --allow-insecure-unlock
./build/bin/geth --datadir data/node2 --ipcdisable --port 30302 --authrpc.port 8552 --bootnodes "$NODE_KEY" --networkid 666 --http --http.addr 'localhost' --http.port 8201 --http.api 'admin,debug,eth,miner,net,personal,txpool,web3' --ws --ws.addr 'localhost' --ws.port 8203 --ws.api 'admin,debug,eth,miner,net,personal,txpool,web3' --allow-insecure-unlock

export MinerAddress=0x237Eb05557844aBAEE6D1f1156Db523B5693Cb04
./build/bin/geth --datadir data/miner --ipcdisable --port 30304 --authrpc.port 8554 --networkid 666 --bootnodes "$NODE_KEY" --mine --miner.etherbase "$MinerAddress" --unlock "$MinerAddress" --password ./password.txt --http --http.port 8545 --http.api "personal,eth,net,web3,admin" --ws --ws.addr 'localhost' --ws.port 8402 --ws.api 'admin,debug,eth,miner,net,personal,txpool,web3' --allow-insecure-unlock


export TFHE_EXECUTOR_CONTRACT_ADDRESS=0x5d
export FHEVM_GO_KEYS_DIR=./fhekeys
./build/bin/geth attach http://localhost:8545

personal.unlockAccount(eth.accounts[0])
eth.sendTransaction({from: eth.accounts[0], to:"0x77B2d1512F177243A5DAcAfeba1FA16E0ca72C5C", value: 100000000000000000})