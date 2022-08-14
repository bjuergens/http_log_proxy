
a simple dockerimage for a proxy that logs http-bodys (both requests and responses). Based on nginx/alpine. 

source-code: https://github.com/bjuergens/http_log_proxy

docker-image: https://hub.docker.com/r/bjuergens/http_log_proxy


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
            image: bjuergens/http_log_proxy
            ports:
                - 80:80

and you will start to see log-messages for your requests in your `docker compose logs`, like this 

    http_log_1     | 172.18.0.1-[14/Aug/2022:06:58:05 +0000]GET / HTTP/1.1200615curl/7.81.00.001<([host localhost]\n[user-agent curl/7.81.0]\n[accept */*]\n)>(content-type=text/html content-length=615 accept-ranges=bytes last-modified=Tue, 19 Jul 2022 14:05:27 GMT connection=keep-alive etag=\"62d6ba27-267\" )<!DOCTYPE html>\n<html>\n<head>\n<title>Welcome to nginx!</title>....

for a little more complex example using optional env-vars, see the [composefile in this repo](https://github.com/bjuergens/http_log_proxy/blob/master/docker-compose.yml)

# customization 

## via environment variables 

the container uses some env-variables which allow runtime customization. A full list can be found in the [Dockerfile](https://github.com/bjuergens/http_log_proxy/blob/master/Dockerfile). Some notable env variables are:

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

if env-vars are not enough, you can always mount new configfiles as volumes. Note that known configs (`nginx.conf` and `proxy.conf`) are created from template-files, while any new configs you may create will be used directly. 


## alternatives

this image aimes to be a simple and uncomplicated way to get a quick glance into the http-requests for a single services. The simplicity comes at the cost of generality. If your situation requires a more sophisticated and heavier solution, consider some of the alternatives, e.g

* https://github.com/nginx-proxy/nginx-proxy
* https://docs.mitmproxy.org/stable/

on the other hand if you can think of a useful feature, that doesn't add too much complexity, feel free to let me know and open an issue. 

## known restriction/limitations

the response-headers `Date` and `Server` do not show up in the respective variable and thus can not be logged. This limitation comes from nginx. If you find a workaround/solution to this limitation, please let me know by opening an issue.

the logs will probably contain many sensible information and even GDPR violations, so I recommend using this image for debugging purposes only. If you find a good use case for this image beside debugging, feel free to let me know. 


# dev info

here is some stuff I am sure to forget until the next time I do maintenance on this repo

relevant dev-reading

* https://github.com/docker-library/docs/tree/master/nginx#using-environment-variables-in-nginx-configuration-new-in-119
* https://www.hardill.me.uk/wordpress/2018/03/14/logging-requests-and-response-with-nginx/


## update image

    docker login -u bjuergens
    docker build -t bjuergens/http_log_proxy --pull .
    docker run -it bjuergens/http_log_proxy # rudimentary test
    docker push bjuergens/http_log_proxy

optional: update readme in dockerhub (leave out dev-section)

