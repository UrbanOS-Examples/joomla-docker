FROM joomla:latest

ENV AWS_ACCESS_KEY \
    AWS_SECRET_KEY \
    S3_BUCKET_NAME=scos-prod-joomla-backups \
    AWS_REGION=us-east-2 \
    S3_FILE_NAME \
    JOOMLA_SITE_NAME=Smart Columbus Operating System \
    JOOMLA_ADMIN_EMAIL \
    JOOMLA_SITE_URL=http://www.smartcolumbusos.com \
    JOOMLA_DB_HOST \
    JOOMLA_DB_USER \
    JOOMLA_DB_PASSWORD \
    JOOMLA_DB_NAME \
    JOOMLA_DB_PREFIX

COPY unite.phar /opt/

RUN apt-get update && apt-get install --no-install-recommends -y \
    awscli

COPY launch.sh /opt/

ENTRYPOINT /opt/launch.sh
