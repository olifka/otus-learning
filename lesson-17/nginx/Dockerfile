FROM alpine:3.12.1
RUN apk add --update nginx && rm -rf /var/cache/apk/* && mkdir -p /run/nginx && \
    ln -sf /dev/stdout /var/log/nginx/access.log && ln -sf /dev/stderr /var/log/nginx/error.log

COPY ./data/default.conf /etc/nginx/conf.d/default.conf
COPY ./data/index.html /usr/share/nginx/html/

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
