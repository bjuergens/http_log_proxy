
a simple dockerimage for a proxy that logs http-bodys (both requests and responses). 


inspired by

* https://serverfault.com/questions/361556/is-it-possible-to-log-the-response-data-in-nginx-access-log
* https://gist.github.com/morhekil/1ff0e902ed4de2adcb7a


relevant dev-reading

* https://github.com/docker-library/docs/tree/master/nginx#using-environment-variables-in-nginx-configuration-new-in-119
* https://www.hardill.me.uk/wordpress/2018/03/14/logging-requests-and-response-with-nginx/


related/relevant alternatives

* https://github.com/nginx-proxy/nginx-proxy
* https://docs.mitmproxy.org/stable/




# todo 

warum produzieren diese beiden methoden unterschiedlcihe ergebnisse? 

bei `set_by_lua_block` kommt nur der `connect=keep-alive` header an. Bei dem anderen komme 6 weiter header (aber im browser wird auch noch `Server nginx/1.20.2` angezeigt, der bei beiden fehlt

    set_by_lua_block $resp_headers{
        local resp_headers_all = ""
        for k, v in pairs(ngx.resp.get_headers()) do
            resp_headers_all = resp_headers_all .. k.."="..v.." "

        end
        return resp_headers_all
    }
    set $resp_headers_old "";
    header_filter_by_lua '
        local rh = ngx.resp.get_headers()
        for k, v in pairs(rh) do
            ngx.var.resp_headers_old = ngx.var.resp_headers_old .. k.."="..v.." "
        end
    ';