#!/bin/bash
timedatectl set-timezone Europe/Kiev
apt install -y sudo curl gnupg2 python3-dev git libsasl2-dev libldap2-dev python3-venv libmariadb-dev pkg-config build-essential libpq-dev nginx libssl-dev libxml2-dev libxslt1-dev libxmlsec1-dev libffi-dev apt-transport-https virtualenv python3-flask
sudo sh -c 'echo "deb https://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list'
wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -
sudo apt-get update
sudo apt-get -y install postgresql
sudo apt-get install -y pdns-server pdns-backend-pgsql
systemctl disable systemd-resolved
systemctl stop systemd-resolved
mkdir -p /opt/pdns_install
workpath="/opt/pdns_install"
pdns_db="db_pdns"
pdns_db_user="u_pdns"
pdns_pwd="$(tr -dc A-Za-z0-9 </dev/urandom | head -c 13 ; echo '')"
echo "pdns_db=$pdns_db" > "$workpath/db_credentials"
echo "pdns_db_user=$pdns_db_user" >> "$workpath/db_credentials"
echo "pdns_pwd=$pdns_pwd" >> "$workpath/db_credentials"
psql_version=$(psql -V|awk -F " " '{print $NF}'|awk -F "." '{print $1}')
echo "psql_version=$psql_version" >> "$workpath/db_credentials"
echo "workpath=$workpath" >> "$workpath/db_credentials"
chown root:root "$workpath/db_credentials"
chmod 640 "$workpath/db_credentials"
cd "$workpath"
echo \
"-- PowerDNS PGSQL Create DB File
CREATE USER $pdns_db_user WITH ENCRYPTED PASSWORD '$pdns_pwd';
CREATE DATABASE $pdns_db OWNER $pdns_db_user;
GRANT ALL PRIVILEGES ON DATABASE $pdns_db TO $pdns_db_user;" > "$workpath/pdns-createdb-pg.sql"
sudo -u postgres psql < "$workpath/pdns-createdb-pg.sql"
sed -i "/# TYPE  DATABASE        USER            ADDRESS                 METHOD/a local   $pdns_db         $pdns_db_user                                  md5" "/etc/postgresql/$psql_version/main/pg_hba.conf"
pg_ctlcluster $psql_version main reload
wget https://raw.githubusercontent.com/PowerDNS/pdns/rel/auth-4.2.x/modules/gpgsqlbackend/schema.pgsql.sql
export PGPASSWORD="$pdns_pwd"
psql -U $pdns_db_user -f schema.pgsql.sql $pdns_db
unset PGPASSWORD
cp /usr/share/doc/pdns-backend-pgsql/examples/pdns.local.gpgsql.conf /etc/powerdns/pdns.d/gpgsql.conf
db_type="pgsql"
db_config_file="/etc/powerdns/pdns.d/gpgsql.conf"
sed -i "s/\(^g$db_type-dbname=\).*/\1$pdns_db/" "$db_config_file"
sed -i "s/\(^g$db_type-host=\).*/\1127.0.0.1/" "$db_config_file"
sed -i "s/\(^g$db_type-password=\).*/\1$pdns_pwd/" "$db_config_file"
sed -i "s/\(^g$db_type-port=\).*/\15432/" "$db_config_file"
sed -i "s/\(^g$db_type-user=\).*/\1$pdns_db_user/" "$db_config_file"
rm -rf /etc/powerdns/pdns.d/bind.conf
systemctl restart pdns.service
pdnsadmin_salt="$(tr -dc A-Za-z0-9 </dev/urandom | head -c 32 ; echo '')"
pdns_apikey="$(tr -dc A-Za-z0-9 </dev/urandom | head -c 32 ; echo '')"
pdns_admin_db="db_pdns_adm"
pdns_admin_db_user="u_pdns_adm"
pdns_admin_db_pws="$(tr -dc A-Za-z0-9 </dev/urandom | head -c 13 ; echo '')"
echo pdnsadmin_salt="$pdnsadmin_salt" >> "$workpath/db_credentials"
echo pdns_apikey="$pdns_apikey" >> "$workpath/db_credentials"
echo "##---PowerDNS-admin---" >> "$workpath/db_credentials"
echo pdns_admin_db="$pdns_admin_db" >> "$workpath/db_credentials"
echo pdns_admin_db_user="$pdns_admin_db_user" >> "$workpath/db_credentials"
echo pdns_admin_db_pws="$pdns_admin_db_pws" >> "$workpath/db_credentials"
echo \
"-- PowerDNS PGSQL Create DB File
CREATE USER $pdns_admin_db_user WITH ENCRYPTED PASSWORD '$pdns_admin_db_pws';
CREATE DATABASE $pdns_admin_db OWNER $pdns_admin_db_user TEMPLATE template0 ENCODING 'UTF8' LC_COLLATE 'en_US.UTF-8' LC_CTYPE 'en_US.UTF-8';
GRANT ALL PRIVILEGES ON DATABASE $pdns_admin_db TO $pdns_admin_db_user;" > "$workpath/pdns-admin-createdb-pg.sql"
sudo -u postgres psql < "$workpath/pdns-admin-createdb-pg.sql"
sed -i "/# TYPE  DATABASE        USER            ADDRESS                 METHOD/a local   $pdns_admin_db         $pdns_admin_db_user                                  md5" "/etc/postgresql/$psql_version/main/pg_hba.conf"
pg_ctlcluster $psql_version main reload
sed -i 's/^.*api=.*/api=yes/' "/etc/powerdns/pdns.conf"
sed -i 's/^.*api-key=.*/api-key='$pdns_apikey'/' "/etc/powerdns/pdns.conf"
sed -i 's/^.*webserver=.*/webserver=yes/' "/etc/powerdns/pdns.conf"
sed -i 's/^.*webserver-address=.*/webserver-address=127.0.0.1/' "/etc/powerdns/pdns.conf"
sed -i 's/^.*webserver-allow-from=.*/webserver-allow-from=127.0.0.1/' "/etc/powerdns/pdns.conf"
sed -i 's/^.*webserver-port=.*/webserver-port=8081/' "/etc/powerdns/pdns.conf"
systemctl stop pdns
systemctl start pdns
curl -sL https://deb.nodesource.com/setup_20.x | bash -
apt-get update -y
apt-get install nodejs -y
wget -O- https://dl.yarnpkg.com/debian/pubkey.gpg | gpg --dearmor > /etc/apt/trusted.gpg.d/yarnpkg.gpg
echo "deb https://dl.yarnpkg.com/debian/ stable main" > "/etc/apt/sources.list.d/yarn.list"
apt-get update -y
apt-get install yarn -y
git clone https://github.com/PowerDNS-Admin/PowerDNS-Admin.git /var/www/html/pdns
cd "/var/www/html/pdns/"
virtualenv -p python3 flask
source "./flask/bin/activate"
pip install --upgrade pip
pip install -r requirements.txt
pip install psycopg2
deactivate
prod_config="/var/www/html/pdns/configs/production.py"
cp "/var/www/html/pdns/configs/development.py" $prod_config
sed -i "s/#import urllib.parse/import urllib.parse/g" $prod_config
sed -i "s/\(^SALT = \).*/\1\'$pdnsadmin_salt\'/" $prod_config
sed -i "s/\(^SECRET_KEY = \).*/\1\'$pdns_apikey\'/" $prod_config
sed -i "s/^\(SQLA_DB_USER = .*\)/#\1/g;
        s/^\(SQLA_DB_PASSWORD = .*\)/#\1/g;
        s/^\(SQLA_DB_HOST = .*\)/#\1/g;
        s/^\(SQLA_DB_NAME = .*\)/#\1/g;
        s/^\(SQLALCHEMY_TRACK_MODIFICATIONS = .*\)/#\1/g" $prod_config
sed -i "s/\(^SQLALCHEMY_DATABASE_URI = 'sqlite.*\)/#\1/" $prod_config
echo "SQLALCHEMY_DATABASE_URI = 'postgresql://$pdns_admin_db_user:$pdns_admin_db_pws@127.0.0.1/$pdns_admin_db'" >> $prod_config
cd "/var/www/html/pdns/"
source "./flask/bin/activate"
export FLASK_APP=powerdnsadmin/__init__.py
export FLASK_CONF=../configs/production.py
flask db upgrade
yarn install --pure-lockfile
flask assets build
deactivate
echo "[Unit]
Description=PowerDNS-Admin
Requires=pdnsadmin.socket
After=network.target

[Service]
PIDFile=/run/pdnsadmin/pid
User=pdns
Group=pdns
Environment=\"FLASK_CONF=../configs/production.py\"
WorkingDirectory=/var/www/html/pdns
ExecStart=/var/www/html/pdns/flask/bin/gunicorn --pid /run/pdnsadmin/pid --bind unix:/run/pdnsadmin/socket 'powerdnsadmin:create_app()'
ExecReload=/bin/kill -s HUP \$MAINPID
ExecStop=/bin/kill -s TERM \$MAINPID
PrivateTmp=true

[Install]
WantedBy=multi-user.target" > /etc/systemd/system/pdnsadmin.service

echo "[Unit]
Description=PowerDNS-Admin socket

[Socket]
ListenStream=/run/pdnsadmin/socket

[Install]
WantedBy=sockets.target" > /etc/systemd/system/pdnsadmin.socket
IP=$(hostname -I | cut -d' ' -f1)
echo IP="$IP" >> "$workpath/db_credentials"
tee /etc/nginx/conf.d/pdns-admin.conf > /dev/null << EOF
server {
	listen  *:80;
	server_name               $IP;

	index                     index.html index.htm index.php;
	root                      /var/www/html/pdns;
	access_log                /var/log/nginx/pdnsadmin_access.log combined;
	error_log                 /var/log/nginx/pdnsadmin_error.log;

	client_max_body_size              10m;
	client_body_buffer_size           128k;
	proxy_redirect                    off;
	proxy_connect_timeout             90;
	proxy_send_timeout                90;
	proxy_read_timeout                90;
	proxy_buffers                     32 4k;
	proxy_buffer_size                 8k;
	proxy_set_header                  Host \$host;
	proxy_set_header                  X-Real-IP \$remote_addr;
	proxy_set_header                  X-Forwarded-For \$proxy_add_x_forwarded_for;
	proxy_headers_hash_bucket_size    64;

	location ~ ^/static/  {
		include  /etc/nginx/mime.types;
		root /var/www/html/pdns/powerdnsadmin;

		location ~*  \.(jpg|jpeg|png|gif)$ {
		expires 365d;
		}

		location ~* ^.+.(css|js)$ {
		expires 7d;
		}
	}

	location / {
		proxy_pass            http://unix:/run/pdnsadmin/socket;
		proxy_read_timeout    120;
		proxy_connect_timeout 120;
		proxy_redirect        off;
	}
}
EOF
chown -R pdns:www-data "/var/www/html/pdns"
nginx -t && systemctl restart nginx
echo "d /run/pdnsadmin 0755 pdns pdns -" >> "/etc/tmpfiles.d/pdnsadmin.conf"
mkdir "/run/pdnsadmin/"
chown -R pdns: "/run/pdnsadmin/"
chown -R pdns: "/var/www/html/pdns/powerdnsadmin/"
systemctl daemon-reload
systemctl enable --now pdnsadmin.service pdnsadmin.socket
pdns_version=$(pdnsutil --version | awk '{print $2}')
echo "Webserver= http://$IP" > $workpath/credentials_for_connect
echo "PowerDNS API URL= http://127.0.0.1:8081" >> $workpath/credentials_for_connect
echo "PowerDNS API Key= $pdns_apikey" >> $workpath/credentials_for_connect
echo "PowerDNS Version= $pdns_version" >> $workpath/credentials_for_connect
clear
cat $workpath/credentials_for_connect