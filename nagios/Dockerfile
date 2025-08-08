FROM jasonrivers/nagios:latest
COPY ./plugins/*.sh /opt/nagios/libexec/custom/
RUN apt update && apt install -y default-mysql-client
RUN chmod +x /opt/nagios/libexec/custom/*.sh
RUN echo 'use_authentication=0' >> /opt/nagios/etc/cgi.cfg