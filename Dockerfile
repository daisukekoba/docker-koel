FROM alpine:edge
MAINTAINER Etopian Inc. <contact@etopian.com>



LABEL   devoply.type="site" \
        devoply.cms="koel" \
        devoply.framework="laravel" \
        devoply.language="php" \
        devoply.require="mariadb etopian/nginx-proxy" \
        devoply.description="Koel music player." \
        devoply.name="Koel" \
        devoply.params="docker run -d --name {container_name} -e VIRTUAL_HOST={virtual_hosts} -v /data/sites/{domain_name}:/DATA etopian/docker-koel"


RUN apk update \
    && apk add bash less vim nginx ca-certificates nodejs \
    php-fpm php-json php-zlib php-xml php-pdo php-phar php-openssl \
    php-pdo_mysql php-mysqli \
    php-gd php-iconv php-mcrypt \
    php-mysql php-curl php-opcache php-ctype php-apcu \
    php-intl php-bcmath php-dom php-xmlreader mysql-client && apk add -u musl

RUN apk add git build-base

RUN apk add python

RUN rm -rf /var/cache/apk/*

ENV TERM="xterm" \
    DB_HOST="172.17.0.1" \
    DB_NAME="" \
    DB_USER=""\
    DB_PASS=""


VOLUME ["/DATA"]



RUN sed -i 's/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/g' /etc/php/php.ini && \
    sed -i 's/nginx:x:100:101:Linux User,,,:\/var\/www\/localhost\/htdocs:\/sbin\/nologin/nginx:x:100:101:Linux User,,,:\/DATA:\/bin\/bash/g' /etc/passwd && \
    sed -i 's/nginx:x:100:101:Linux User,,,:\/var\/www\/localhost\/htdocs:\/sbin\/nologin/nginx:x:100:101:Linux User,,,:\/DATA:\/bin\/bash/g' /etc/passwd-

ADD files/nginx.conf /etc/nginx/
ADD files/php-fpm.conf /etc/php/
ADD files/run.sh /
RUN chmod +x /run.sh && chown nginx:nginx /DATA

RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/bin --filename=composer 

RUN su nginx && git clone https://github.com/phanan/koel /DATA/htdocs &&\
    cd /DATA/htdocs &&\
    npm install &&\
    composer install

COPY files/.env /DATA/htdocs/.env

#RUN cd /DATA/htdocs && php artisan init

EXPOSE 80
CMD ["/run.sh"]
