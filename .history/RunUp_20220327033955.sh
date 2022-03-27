#!/bin/bash

apt-get update

git clone https://github.com/lihaybs/bootcamp-app.git

cd /bootcamp-app

curl -sL https://deb.nodesource.com/setup_14.x | sudo bash - #downloading nodejs libaries

DEBIAN_FRONTEND=noninteractive apt-get install -y postgresql-client nodejs

npm install dotenv

npm install pm2@latest -g # insatalling pm2 for the app to run automaticlly after machine reboot

cat <<EOF >.env
# Host configuration
PORT=8080
HOST=0.0.0.0


HOST_URL=http://20.121.73.232:8080
COOKIE_ENCRYPT_PWD=superAwesomePasswordStringThatIsAtLeast32CharactersLong!
NODE_ENV=development

# Okta configuration
OKTA_ORG_URL=https://dev-50792663.okta.com
OKTA_CLIENT_ID=0oa3ytguv8aug1PTu5d7
OKTA_CLIENT_SECRET=XRTjnYOnUO-gvWTnIcTjtyBGxCFjWIokmZIoOYhx

# Postgres
PGHOST=10.30.2.4
PGUSERNAME=postgres
PGDATABASE=postgres
PGPASSWORD=Hakolzorem2022
PGPORT=5432
EOF

npm run initdb #initializing the data base

pm2 start "npm run dev" #starting the app and saving it to pm2 watch list

pm2 save # saving pm2 watch list 
