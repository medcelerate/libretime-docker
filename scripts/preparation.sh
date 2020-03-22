### VERSION
version="3.0.0-alpha.8"

### POSTGRES CONFIG
echo "host    all             all             0.0.0.0/0 trust" >> /etc/postgresql/10/main/pg_hba.conf
echo "listen_addresses='*'" >> /etc/postgresql/10/main/postgresql.conf
pg_ctlcluster 10 main start

# LIBRETIME TWEAKING
cd "libretime-${version}"
sed '/pid=1 following any symlinks/a \ \ \ \ has_systemd_init=true; verbose "Detected init system type: systemd"; return 0' install > mod_install

mv mod_install install
chmod u+x install

sed -i "/subprocess.call('kill -9/a \ \ \ \ \ \ \ \ \ \ \ \ os.system('sh \/libre_start.sh')" python_apps/pypo/pypo/pypofetch.py > mod_fetch

# NECESSARY PYTHON INSTALL
pip install more-itertools

### RABBITMQ SETUP
echo "** Activating rabbitmq"
echo "NODENAME=rabbitmq@localhost" > /etc/rabbitmq/rabbitmq-env.conf
rabbitmq-plugins enable rabbitmq_management
/etc/init.d/rabbitmq-server start

### LIBRETIME INSTALL
echo "** Installing libretime"
./install -fiap
/etc/init.d/rabbitmq-server stop
cd / && rm -rf /src

## APACHE RESTART
a2enmod rewrite
systemctl restart apache2

## Setup postgres config
echo "** Creating config files"
echo "localhost:5432:libretime:$POSTGRES_USER:$POSTGRES_PASSWORD" > /root/.pgpass
chmod 600 /root/.pgpass