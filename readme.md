
a simple dockerimage for a proxy that logs http-bodys (both requests and responses). 


inspired by

* https://serverfault.com/questions/361556/is-it-possible-to-log-the-response-data-in-nginx-access-log
* https://gist.github.com/morhekil/1ff0e902ed4de2adcb7a

# quickstart

Simply create a new service from this image, move the port from the target container to this one, and pass the name of the target container as $TARGET_HOST to this new service. 

## example

if your initial compose file looks like this:

    version: "3.8"
    services:
        example_web:
            image: nginx
            ports:
                - 80:80

then your new dockerfile will look like this 
  
    version: "3.8"
    services:
        example_web:
            image: nginx
        http_log:
            environment:
                TARGET_HOST: example_web
            image: http_log_proxy
            ports:
                - 80:80

# customization 

## via environment variables 

the container uses some env-variables which allow runtime customization. A full list can be found in the [[Dockerfile]]. Some notable env variables are:

* `TARGET_HOST` (no default, required): where should all requests be redirected to?
* `TARGET_PORT` (default `80`)
* `LOG_MAX_BODY_LENGTH` (default `1000`): limits the how many symbols of the body can be logged per request
* `LOG_FORMAT_ESCAPE` (default `json`): decides what kind of escaping the values in each log-message should go through
* `LOG_FORMAT`: format string for log-messages. 
* `EXTRA_DIRECTIVES_ROOT`: additional directives for the root-block of `nginx.conf`
* `EXTRA_DIRECTIVES_HTTP`: additional directives for the http-block of nginx.conf
* `EXTRA_DIRECTIVES_SERVER`: additional directives for for the default `server` block
* `EXTRA_DIRECTIVES_LOCATION`: additional directives for the default `location` block
* `DEFAULT_DIRECTIVES_PROXY`: default directives for the location block, which should work for most reverse-proxy-situations

The variable `LOG_FORMAT` uses [nginx's own log_format directrive](http://nginx.org/en/docs/http/ngx_http_log_module.html#log_format) and thus all usual nginx-variables are available. This docker image supplies additional variables which can (and should!) be used for logging:

* `$requ_headers` all request-headers
* `$request_body` full request body
* `$resp_body` full response body, truncated to `$LOG_MAX_BODY_LENGTH`
* `$resp_headers_full` all response-headers (except `Date` and `Server`)
* `$resp_headers_short` response-headers without fast-path headers, which usually add clutter and a boring (for details see [this comment](https://github.com/openresty/lua-nginx-module/issues/1595#issuecomment-530597829))

## via config files

if env-vars 



# restriction/limitations



# dev

relevant dev-reading

* https://github.com/docker-library/docs/tree/master/nginx#using-environment-variables-in-nginx-configuration-new-in-119
* https://www.hardill.me.uk/wordpress/2018/03/14/logging-requests-and-response-with-nginx/


related/relevant alternatives

* https://github.com/nginx-proxy/nginx-proxy
* https://docs.mitmproxy.org/stable/


