FROM nginx:latest

RUN apt update && apt install -y openssl && \
    openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout /etc/ssl/private/nginx-selfsigned.key \
    -out /etc/ssl/certs/nginx-selfsigned.crt \
    -subj "/C=US/ST=Ohio/L=Columbus/O=Columbus/OU=IT Department/CN=www.smartcolumbusos.com" && \
    openssl dhparam -out /etc/ssl/certs/dhparam.pem 2048

COPY nginx.conf /etc/nginx/conf.d/default.conf

ENV NGINX_HOST=www.smartcolumbusos.com

CMD envsubst '${NGINX_HOST}' < /etc/nginx/conf.d/default.conf > /etc/nginx/conf.d/default.conf \
    && exec nginx -g 'daemon off;'