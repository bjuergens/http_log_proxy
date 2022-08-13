
# from nginx:1.23-alpine
# run apk update && apk add --no-cache nginx-mod-http-lua

from alpine:3.15
run apk update && apk add --no-cache nginx nginx-mod-http-lua gettext

copy proxy.conf.template /etc/nginx/conf.d/

copy nginx.conf.template /etc/nginx/

cmd envsubst '' < /etc/nginx/nginx.conf.template > /etc/nginx/nginx.conf \
 && envsubst '' < /etc/nginx/conf.d/proxy.conf.template > /etc/nginx/conf.d/proxy.conf \
 && nginx -t \
 && nginx
