
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
env LOG_FORMAT '$remote_addr - $remote_user [$time_local] \
"$request" $status $body_bytes_sent \
"$http_referer" "$http_user_agent" $request_time \
< ($requ_headers) "$request_body" > ($resp_headers_full) "$resp_body"'
env TARGET_HOST ""
env TARGET_PORT 80
env OWN_PORT    80

env ERROR_LOG_LEVEL notice
env ERROR_LOG_TARGET /var/log/nginx/error.log

env DEFAULT_DIRECTIVES_PROXY '\
        proxy_set_header Host               $host;\
        proxy_set_header Upgrade            $http_upgrade;\
        proxy_set_header X-Real-IP          $remote_addr;\
        proxy_set_header X-Forwarded-Host   $host;\
        proxy_set_header X-Forwarded-Port   $server_port;\
        proxy_set_header X-Forwarded-Proto  $scheme;\
        proxy_set_header X-Forwarded-For    $proxy_add_x_forwarded_for;\
        proxy_buffering             off;\
        proxy_request_buffering     off;\
        proxy_max_temp_file_size    0;\
        proxy_connect_timeout       90;\
        proxy_send_timeout          90;\
        proxy_read_timeout          90;\
        client_max_body_size        10m;\
        client_body_buffer_size     128k;\
'
env EXTRA_DIRECTIVES_ROOT ""
env EXTRA_DIRECTIVES_HTTP ""
env EXTRA_DIRECTIVES_SERVER ""
env EXTRA_DIRECTIVES_LOCATION ""

cmd echo $TARGET_HOST; if [ -z "${TARGET_HOST}" ]; then echo "variable \$TARGET_HOST not set"; exit 1; fi \
 && envsubst '$ERROR_LOG_TARGET, $ERROR_LOG_LEVEL, $EXTRA_DIRECTIVES_ROOT, $EXTRA_DIRECTIVES_HTTP' < /etc/nginx/nginx.conf.template > /etc/nginx/nginx.conf \
 && envsubst '$OWN_PORT, $EXTRA_DIRECTIVES_LOCATION, $EXTRA_DIRECTIVES_SERVER, $DEFAULT_DIRECTIVES_PROXY, $LOG_FORMAT_ESCAPE, $LOG_MAX_BODY_LENGTH,$TARGET_HOST,$LOG_FORMAT,$TARGET_PORT' < /etc/nginx/conf.d/proxy.conf.template > /etc/nginx/conf.d/proxy.conf \
 && nginx -t \
 && nginx
