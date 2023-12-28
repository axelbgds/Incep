FROM alpine:3.18

RUN apk update && apk upgrade && apk add --no-cache nginx && apk add --no-cache openssl

# https://www.baeldung.com/openssl-self-signed-cert
RUN openssl req -x509 -sha256 -nodes -days 365 -newkey rsa:2048 -keyout /etc/ssl/private/abeaugra.42.fr.key -out /etc/ssl/certs/abeaugra.42.fr.crt -subj "/C=FR"

# Accept incoming connections on port 443 used for HTTPS traffic when Nginx service is open
EXPOSE 443

# Command that should be executed when the container is started
# It starts the NGINX web server with the '-g' option to set a configuration option and the 'daemon off' option
# The 'daemon off' option prevents NGINX from running as a background daemon where NGINX spawns its processes and then just quit
# daemon off -> https://hub.docker.com/r/yobasystems/alpine-nginx/
CMD ["nginx", "-g", "daemon off;"]
