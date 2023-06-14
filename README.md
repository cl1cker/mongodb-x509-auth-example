# MongoDB Use x.509 Certificates to Authenticate Clients

To run the test:
```
./create_certs.sh
./run.sh
```

If successful, the output will show the output of `db.runCommand({connectionStatus : 1})` (e.g. `whoami`) from a connection using x.509 external auth.

The test connects using `mongosh`:
```
docker exec -i mongo-mongo-1 mongosh --quiet --tlsCAFile ./certs/ca.crt.pem -tlsCertificateKeyFile ./certs/client.bundle.pem --tls \
    --authenticationDatabase '$external' --authenticationMechanism MONGODB-X5
```

and the output should be:
```
test> {
  authInfo: {
    authenticatedUsers: [ { user: 'CN=client', db: '$external' } ],
    authenticatedUserRoles: [
      { role: 'userAdminAnyDatabase', db: 'admin' },
      { role: 'readWrite', db: 'test' }
    ]
  },
  ok: 1
}
```

The `run.sh` script also shows how to authenticate *after* connecting using `db.auth()`.
