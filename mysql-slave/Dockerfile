FROM mysql:5.7

COPY slave-init.sh /docker-entrypoint-initdb.d/
RUN chmod +x /docker-entrypoint-initdb.d/slave-init.sh