#!/bin/bash
mkdir -p /srv/airtime/stor
chown -R www-data:www-data /srv/airtime
chown -R www-data:www-data /etc/airtime
chown -R postgres:postgres /var/lib/postgresql

echo "Restarting postgres DB"
pg_ctlcluster 10 main restart

echo "Setting Up postgres"
sudo -u postgres psql --command "CREATE USER $POSTGRES_USER WITH SUPERUSER PASSWORD '$POSTGRES_PASSWORD' CREATEDB;"
echo "Creating db"
sudo -u postgres createdb -O $POSTGRES_USER airtime
echo "Creating Access rules"

if [ -e /liquidsoap ]
then
  echo "Setting up liquidsoap dir"
  mv /liquidsoap/* /usr/local/lib/python2.7/dist-packages/airtime_playout-1.0-py2.7.egg/liquidsoap/
  rm -rf /liquidsoap
fi

echo "Restarting libretime services"
/libre_start.sh

#Setup RabbitMQ
echo "Setting Up Rabbit"
rabbitmqctl add_user airtime airtime
rabbitmqctl set_user_tags airtime administrator
rabbitmqctl set_permissions -p /airtime airtime ".*" ".*" ".*"


echo "Starting libretime container..."

### NECESSARY LIQUIDSOAP CHANGES
chown root:www-data /usr/bin/systemctl
chmod 770 /usr/bin/systemctl 
chown root:www-data /var/run/airtime-liquidsoap.service.status /var/log/journal/airtime-liquidsoap.service.log
chmod 770 /var/run/airtime-liquidsoap.service.status /var/log/journal/airtime-liquidsoap.service.log

