#!/bin/bash

port=$(reserve_port)

mkdir server
cd server
zold node --trace --invoice=PUSHNPULL@ffffffffffffffff \
  --host=127.0.0.1 --port=${port} --bind-port=${port} \
  --threads=0 --standalone &
pid=$!
trap "halt_nodes ${port}" EXIT
cd ..

wait_for_port ${port}

zold remote clean
zold remote add 127.0.0.1 ${port}
zold remote trim
zold remote show

zold --public-key=id_rsa.pub create 0000000000000000
target=$(zold create --public-key=id_rsa.pub)
invoice=$(zold invoice ${target})
zold pay --private-key=id_rsa 0000000000000000 ${invoice} 14.99 'To save the world!'
zold propagate
zold propagate 0000000000000000
zold show
zold show 0000000000000000
zold taxes debt 0000000000000000

zold remote show
zold push
zold push 0000000000000000
until zold fetch 0000000000000000 --ignore-score-weakness; do
  echo 'Failed to fetch, let us try again'
  sleep 1
done
zold fetch
zold diff 0000000000000000
zold merge
zold merge 0000000000000000
zold clean
zold clean 0000000000000000
zold remove
