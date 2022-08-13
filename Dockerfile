
# from nginx:1.23-alpine
# run apk update && apk add --no-cache nginx-mod-http-lua

from alpine:3.15
run apk update && apk add --no-cache nginx nginx-mod-http-lua gettext

copy proxy.conf.template /etc/nginx/conf.d/

copy nginx.conf.template /etc/nginx/

# options: default|json|none
# see http://nginx.org/en/docs/http/ngx_http_log_module.html#log_format
env LOG_FORMAT_ESCAPE json

env LOG_MAX_BODY_LENGTH 1000
env TARGET_HOST ""
env TARGET_PORT 80

env LOG_FORMAT '$remote_addr - $remote_user [$time_local] \
"$request" $status $body_bytes_sent \
"$http_referer" "$http_user_agent" $request_time \
< ($requ_headers) "$request_body" > ($resp_headers) "$resp_body"'

cmd echo $TARGET_HOST; if [ -z "${TARGET_HOST}" ]; then echo "variable \$TARGET_HOST not set"; exit 1; fi \
 && envsubst '' < /etc/nginx/nginx.conf.template > /etc/nginx/nginx.conf \
 && envsubst '$LOG_FORMAT_ESCAPE, $LOG_MAX_BODY_LENGTH,$TARGET_HOST,$LOG_FORMAT,$TARGET_PORT' < /etc/nginx/conf.d/proxy.conf.template > /etc/nginx/conf.d/proxy.conf \
 && nginx -t \
 && nginx
