#!/bin/bash -e

[ "${S3_FILE_NAME}" = "$(cat /var/www/html/restored)" ] && exit 0

cat <<EOF >/var/www/html/.htaccess
RewriteEngine On

RewriteBase "/"
RewriteRule ^(.*) / [R=503,L]
EOF

vars=(
  AWS_ACCESS_KEY
  AWS_SECRET_KEY
  AWS_REGION
  S3_BUCKET_NAME
  S3_FILE_NAME
  JOOMLA_SITE_NAME
  JOOMLA_SITE_URL
  JOOMLA_ADMIN_EMAIL
  JOOMLA_DB_HOST
  JOOMLA_DB_USER
  JOOMLA_DB_PASSWORD
  JOOMLA_DB_NAME
  JOOMLA_DB_PREFIX
)

abort=false

for var in "${vars[@]}"; do
  if [ -z "${!var}" ]; then
    echo "Environment variable ${var} was not set."
    abort=true
  fi
done

if ${abort}; then
  echo "Aborting!"
  exit 1
fi

aws configure set aws_access_key_id ${AWS_ACCESS_KEY}
aws configure set aws_secret_access_key ${AWS_SECRET_KEY}
aws configure set region ${AWS_REGION}

aws s3 cp s3://${S3_BUCKET_NAME}/${S3_FILE_NAME} /tmp/

cat <<EOF >/tmp/restore_config.xml
<?xml version="1.0" encoding="UTF-8"?>
<unite scripting="02_angie">
  <siteInfo>
    <package>/tmp/${S3_FILE_NAME}</package>
    <deletePackage>0</deletePackage>
    <localLog>test.log</localLog>
    <emailSysop>0</emailSysop>
    <name>${JOOMLA_SITE_NAME}</name>
    <email>${JOOMLA_ADMIN_EMAIL}</email>
    <absolutepath>/var/www/html</absolutepath>
    <homeurl>${JOOMLA_SITE_URL}</homeurl>
    <livesite>${JOOMLA_SITE_URL}</livesite>
  </siteInfo>

  <databaseInfo>
    <database name="site">
      <changecollation>0</changecollation>
      <dbdriver>mysqli</dbdriver>
      <dbhost>${JOOMLA_DB_HOST}</dbhost>
      <dbuser>${JOOMLA_DB_USER}</dbuser>
      <dbpass>${JOOMLA_DB_PASSWORD}</dbpass>
      <dbname>${JOOMLA_DB_NAME}</dbname>
      <dbprefix>${JOOMLA_DB_PREFIX}</dbprefix>
    </database>
  </databaseInfo>

</unite>
EOF

php /opt/unite.phar /tmp/restore_config.xml --debug

sed -i '25,27s/^/#/' /var/www/html/.htaccess

echo "${S3_FILE_NAME}" > /var/www/html/restored