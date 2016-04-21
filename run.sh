#!/bin/bash


CN=www.example.com
DN=example.com
DNS1=apps.example.com
DNS2=managed.example.com

OPTIONS=" --debug --http-01-port 80 --renew-by-default  --agree-tos --standalone --standalone-supported-challenges http-01"

/bin/bash /opt/letsencrypt/letsencrypt-auto certonly  -d $CN -d $DN -d $DNS1 -d $DNS2 $OPTIONS


# Webmin server, linked to DNS2
WEBMINSVR1=192.168.2.254

scp /etc/letsencrypt/live/$DNS2/cert.pem :/etc/webmin/miniserv.cert
scp /etc/letsencrypt/live/$DNS2/chain.pem WEBMINSVR1:/etc/webmin/miniserv.chain
scp /etc/letsencrypt/live/$DNS2/privkey.pem WEBMINSVR1:/etc/webmin/miniserv.pem
ssh WEBMINSVR1 'service webmin restart'


# HAProxy server cluster, linked to CN
HAPROXYSVR1=192.168.2.230
HAPROXYSVR2=192.168.2.231

#openssl dhparam -out /etc/letsencrypt/live/$CN/dh.pem 2048
cat /etc/letsencrypt/live/$CN/fullchain.pem /etc/letsencrypt/live/$CN/privkey.pem /etc/letsencrypt/live/$CN/dh.pem > /etc/letsencrypt/live/$CN/$CN.pem
scp /root/$CN.pem HAPROXYSVR1:/etc/ssl/common/
scp /root/$CN.pem HAPROXYSVR2:/etc/ssl/common/
ssh HAPROXYSVR1 'service haproxy reload'
ssh HAPROXYSVR2 'service haproxy reload'


# PFSense server, linked to CN
# pfsense server name or IP
PFSENSESVR1=192.168.2.4

# Letencrypt certificate and chain filename (and path)
CRT=/etc/letsencrypt/live/$CN/fullchain.pem
KEY=/etc/letsencrypt/live/$CN/privkey.pem


PHP=`which php`
# ENCERT=`$PHP encode.php  $CERT $CHAIN`
ENCRT=`$PHP -r '$cert = file_get_contents( $argv[1] , true);  echo base64_encode("$cert");' $CRT`
ENKEY=`$PHP -r '$cert = file_get_contents( $argv[1] , true);  echo base64_encode("$cert");' $KEY`


# replace the placeholder string in the pattern template with certificate information.
# awk is used because of the escape characters aren't passed via sed.

cat pattern.template | awk '$1=$1' FS="CRTPLACEHOLDER" OFS="$ENCRT"  | awk '$1=$1' FS="KEYPLACEHOLDER" OFS="$ENKEY" > pattern.sub

# scp the pattern file to the pfsense system
scp pattern.sub $PFSENSESVR1:/tmp/

# execute sed replace against the config.xml and reload the configuration

ssh $PFSENSESVR1 'cp -rf /conf/config.xml /tmp/config.xml && sed -f /tmp/pattern.sub < /tmp/config.xml > /conf/config.xml && rm /tmp/config.cache  && /etc/rc.restart_webgui'
