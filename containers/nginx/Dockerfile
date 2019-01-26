# build off of base nginx image
FROM nginx:latest

# install vim for dev convienence
RUN apt-get update && apt-get install -y vim

# get rid of the default conf
RUN rm /etc/nginx/conf.d/default.conf

# landing page
RUN mkdir -p /var/www/html
COPY index.html /var/www/html/index.html

# restart nginx and run it in the foreground
CMD ["nginx", "-g", "daemon off;"]
