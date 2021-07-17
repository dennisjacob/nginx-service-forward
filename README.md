# Nginx Service Forwarding using Lua script

### Steps to build and set up the lua module in RHEL7

yum install gcc pcre openssl-devel

```
# https://luajit.org/download.html
cd /usr/mware
wget -c https://luajit.org/download/LuaJIT-2.0.4.tar.gz
tar xzvf LuaJIT-2.0.4.tar.gz
cd LuaJIT-2.0.4 &&  make install PREFIX=/usr/mware/luajit

export LUAJIT_LIB=/usr/mware/luajit/lib
export LUAJIT_INC=/usr/mware/luajit/include/luajit-2.0

```

```
# https://github.com/simpl/ngx_devel_kit
cd /usr/mware
wget https://github.com/simpl/ngx_devel_kit/archive/v0.3.0.tar.gz
tar -xzvf v0.3.0.tar.gz
```

```
# https://github.com/openresty/lua-nginx-module/releases
wget https://github.com/openresty/lua-nginx-module/archive/v0.10.9rc7.tar.gz
tar -xzvf v0.10.9rc7.tar.gz
```

```
wget https://nginx.org/download/nginx-1.19.3.tar.gz
tar -xzf nginx-1.19.3.tar.gz
cd nginx-1.19.3
./configure --prefix=/usr/mware/nginx \
               --with-http_ssl_module \
               --with-http_flv_module \
               --with-http_stub_status_module \
               --with-http_gzip_static_module \
               --with-http_realip_module \
               --with-pcre \
               --add-module=/usr/mware/lua-nginx-module-0.10.9rc7 \
               --add-module=/usr/mware/ngx_devel_kit-0.3.0 \
               --with-stream

make
make install

```

```
export LD_LIBRARY_PATH="/usr/mware/luajit/lib:$LD_LIBRARY_PATH"
./nginx -c /usr/mware/nginx/conf/nginx.conf -p /usr/mware/nginx
                               
```







