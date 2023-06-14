#/bin/bash

RED='\033[0;31m'
NC='\033[0m'

cd "$(dirname "$(readlink -f "$0")")"

# Start MongoDB
docker compose up -V --force-recreate -d --wait

echo -e "\n\n${RED}Connect as root and create external user${NC}"
docker exec -i mongo-mongo-1 mongosh --quiet --tlsCAFile ./certs/ca.crt.pem -tlsCertificateKeyFile ./certs/client.bundle.pem --tls -u root -p example <<'EOF'
db.getSiblingDB("$external").runCommand(
  {
    createUser: "CN=client",
    roles: [
         { role: "readWrite", db: "test" },
         { role: "userAdminAnyDatabase", db: "admin" }
    ],
    writeConcern: { w: "majority" , wtimeout: 5000 }
  }
)
EOF

echo -e "\n\n${RED}Connect as client via external auth using mongosh arguments${NC}"
docker exec -i mongo-mongo-1 mongosh --quiet --tlsCAFile ./certs/ca.crt.pem -tlsCertificateKeyFile ./certs/client.bundle.pem --tls \
    --authenticationDatabase '$external' --authenticationMechanism MONGODB-X509 <<'EOF'
db.runCommand({connectionStatus : 1})
EOF

echo -e "\n\n${RED}Connect as client via external auth using db.auth()${NC}"
docker exec -i mongo-mongo-1 mongosh --quiet --tlsCAFile ./certs/ca.crt.pem -tlsCertificateKeyFile ./certs/client.bundle.pem --tls <<'EOF'
db.getSiblingDB("$external").auth(
  {
    mechanism: "MONGODB-X509"
  }
)
db.runCommand({connectionStatus : 1})
EOF
