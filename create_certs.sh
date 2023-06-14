#!/bin/bash

cd "$(dirname "$(readlink -f "$0")")"
test -d certs/ && rm -rf certs/
mkdir -p certs/
pushd certs
openssl req -x509 -days 365 -newkey rsa:4096 -keyout ca.key.pem -out ca.crt.pem -nodes -subj "/CN=CA"
for cn in client mongo ; do
  openssl req -newkey rsa:4096 -nodes -keyout ${cn}.key.pem -out ${cn}.csr -subj "/CN=${cn}" -addext "subjectAltName=DNS:${cn},IP:127.0.0.1"
  openssl x509 -req -days 365 -sha256 -in ${cn}.csr -CA ca.crt.pem -CAkey ca.key.pem -out ${cn}.crt.pem -copy_extensions=copyall
  cat ${cn}.crt.pem ${cn}.key.pem >${cn}.bundle.pem
done

