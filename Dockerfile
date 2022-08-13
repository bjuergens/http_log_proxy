
# from nginx:1.23-alpine
# run apk update && apk add --no-cache nginx-mod-http-lua

from alpine:3.15
run apk update && apk add --no-cache nginx nginx-mod-http-lua

copy proxy.conf /etc/nginx/conf.d/

copy nginx.conf /etc/nginx/


cmd nginx -t && nginx