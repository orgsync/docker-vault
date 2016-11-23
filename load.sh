#!/bin/sh

sed -i -- "s|CONSUL_ADDRESS|$CONSUL_ADDRESS|g" $VAULT_CONFIG

until $(curl --output /dev/null --silent --head --fail http://${CONSUL_ADDRESS}/v1/health/service/consul); do
  sleep 1
done

$VAULT_ENTRYPOINT "$@" &

until $(curl --output /dev/null --silent --head --fail ${VAULT_ADDR}/sys/seal-status); do
  sleep 1
done

curl -X PUT "${VAULT_ADDR}/sys/unseal?key=${UNSEAL_KEY}"

wait $!
