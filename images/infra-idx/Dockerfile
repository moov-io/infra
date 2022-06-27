FROM nginx:1.23
LABEL maintainer="Moov <support@moov.io>"
USER nginx

COPY nginx/nginx.conf /opt/nginx/nginx.conf
COPY nginx/default.conf /opt/nginx/conf.d/default.conf
COPY nginx/metrics /opt/nginx/www/metrics

COPY index.html /opt/nginx/www/index.html

EXPOSE 8080
ENTRYPOINT ["nginx"]
CMD ["-c", "/opt/nginx/nginx.conf"]
