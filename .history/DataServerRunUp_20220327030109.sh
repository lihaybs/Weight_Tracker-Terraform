#!/bin/bash

apt-get update


wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -

echo "deb http://apt.postgresql.org/pub/repos/apt/ $(lsb_release -cs)-pgdg main" | sudo tee /etc/apt/sources.list.d/pgdg.list

apt-get update

apt -y install postgresql-12 postgresql-client-12

sed -ie "/^#listen_addresses/ a listen_addresses = '*'" /etc/postgresql/12/main/postgresql.conf

bash -c "echo host    all          all            0.0.0.0/0  trust >> /etc/postgresql/12/main/pg_hba.conf"

systemctl restart postgresql

#!/bin/bash

# apt-get update

# apt install docker.io -y

# docker pull postgres:latest

# docker run --restart always -d --name measurements -p 5432:5432 -e 'POSTGRES_PASSWORD=Hakolzorem2022' postgres