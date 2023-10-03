FROM ubuntu:18.04

RUN sed -i 's/archive.ubuntu.com/mirrors.aliyun.com/g' /etc/apt/sources.list && apt-get update

RUN apt-get install -y --no-install-recommends build-essential ca-certificates curl gettext-base libgd-dev libgeoip-dev libncurses5-dev libperl-dev libreadline-dev libxslt1-dev make perl unzip wget zlib1g-dev

# install openssl
ARG OPENSSL_VERSION=1.1.1u
RUN cd /tmp && curl -fSL "https://www.openssl.org/source/openssl-${OPENSSL_VERSION}.tar.gz" -o openssl-${OPENSSL_VERSION}.tar.gz && \
    tar xzf openssl-${OPENSSL_VERSION}.tar.gz  && \
    cd /tmp/openssl-${OPENSSL_VERSION} && curl -s https://raw.githubusercontent.com/openresty/openresty/master/patches/openssl-1.1.1f-sess_set_get_cb_yield.patch | patch -p1 && \
    ./config no-threads shared zlib -g enable-ssl3 enable-ssl3-method --prefix=/usr/local/openresty/openssl --libdir=lib -Wl,-rpath,/usr/local/openresty/openssl/lib && \
    make && make install


ARG PCRE_VERSION=8.45
RUN cd /tmp && curl -fSL https://downloads.sourceforge.net/project/pcre/pcre/${PCRE_VERSION}/pcre-${PCRE_VERSION}.tar.gz -o pcre-${PCRE_VERSION}.tar.gz  && \
    tar xzf pcre-${PCRE_VERSION}.tar.gz &&  cd /tmp/pcre-${PCRE_VERSION} && \
    ./configure --prefix=/usr/local/openresty/pcre --disable-cpp --enable-utf --enable-unicode-properties --enable-jit  && \
    make && make install 

ARG OPENRESTY_VERSION=1.21.4.2
RUN cd /tmp &&  curl -fSL https://openresty.org/download/openresty-${OPENRESTY_VERSION}.tar.gz -o openresty-${OPENRESTY_VERSION}.tar.gz && \
    tar xzf openresty-${OPENRESTY_VERSION}.tar.gz && cd /tmp/openresty-${OPENRESTY_VERSION} && \
    ./configure --with-pcre \
    --with-compat \
    --with-file-aio \
    --with-http_addition_module \
    --with-http_auth_request_module \
    --with-http_dav_module \
    --with-http_flv_module \
    --with-http_geoip_module=dynamic \
    --with-http_gunzip_module \
    --with-http_gzip_static_module \
    --with-http_image_filter_module=dynamic \
    --with-http_mp4_module \
    --with-http_random_index_module \
    --with-http_realip_module \
    --with-http_secure_link_module \
    --with-http_slice_module \
    --with-http_ssl_module \
    --with-http_stub_status_module \
    --with-http_sub_module \
    --with-http_v2_module \
    --with-http_xslt_module=dynamic \
    --with-ipv6 \
    --with-mail \
    --with-mail_ssl_module \
    --with-md5-asm \
    --with-sha1-asm \
    --with-stream \
    --with-stream_ssl_module \
    --with-threads \
    --with-luajit-xcflags='-DLUAJIT_NUMMODE=2 -DLUAJIT_ENABLE_LUA52COMPAT' \
    --with-cc-opt='-DNGX_LUA_ABORT_AT_PANIC -I/usr/local/openresty/pcre/include -I/usr/local/openresty/openssl/include' \
    --with-ld-opt='-L/usr/local/openresty/pcre/lib -L/usr/local/openresty/openssl/lib -Wl,-rpath,/usr/local/openresty/pcre/lib:/usr/local/openresty/openssl/lib' \
    --with-pcre-jit && \
    make && make install

RUN wget -O /usr/local/openresty/nginx/html/favicon.ico http://openresty.org/favicon.ico

ENV LUA_PATH="/usr/local/openresty/site/lualib/?.ljbc;/usr/local/openresty/site/lualib/?/init.ljbc;/usr/local/openresty/lualib/?.ljbc;/usr/local/openresty/lualib/?/init.ljbc;/usr/local/openresty/site/lualib/?.lua;/usr/local/openresty/site/lualib/?/init.lua;/usr/local/openresty/lualib/?.lua;/usr/local/openresty/lualib/?/init.lua;./?.lua;/usr/local/openresty/luajit/share/luajit-2.1.0-beta3/?.lua;/usr/local/share/lua/5.1/?.lua;/usr/local/share/lua/5.1/?/init.lua;/usr/local/openresty/luajit/share/lua/5.1/?.lua;/usr/local/openresty/luajit/share/lua/5.1/?/init.lua"

ENV LUA_CPATH="/usr/local/openresty/site/lualib/?.so;/usr/local/openresty/lualib/?.so;./?.so;/usr/local/lib/lua/5.1/?.so;/usr/local/openresty/luajit/lib/lua/5.1/?.so;/usr/local/lib/lua/5.1/loadall.so;/usr/local/openresty/luajit/lib/lua/5.1/?.so"

ENV PATH=$PATH:/usr/local/openresty/luajit/bin:/usr/local/openresty/nginx/sbin:/usr/local/openresty/bin

RUN ln -sf /dev/stdout /usr/local/openresty/nginx/logs/access.log && ln -sf /dev/stderr /usr/local/openresty/nginx/logs/error.log

# nginx环境变量
ENV NGINX_CONF_PATH=

ADD entrypoint.sh /

RUN chmod +x /entrypoint.sh

WORKDIR /usr/local/openresty/nginx/html

RUN apt-get clean && rm -rf /var/lib/apt/lists/*
RUN rm -rf /tmp/*

EXPOSE 80 443

ENTRYPOINT ["/entrypoint.sh"]
# Use SIGQUIT instead of default SIGTERM to cleanly drain requests
# See https://github.com/openresty/docker-openresty/blob/master/README.md#tips--pitfalls
STOPSIGNAL SIGQUIT

