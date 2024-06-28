FROM debian:stable

WORKDIR /usr/backup

RUN apt update && apt install curl mariadb-client cron -y
RUN apt install nano -y

COPY mariadbBackup.sh /usr/backup/mariadbBackup.sh
RUN chmod 0744 /usr/backup/mariadbBackup.sh

COPY crontab /etc/cron.d/mariadb-cron 
RUN chmod 0644 /etc/cron.d/mariadb-cron
RUN crontab /etc/cron.d/mariadb-cron

# Create the log file to be able to run tail
RUN touch /var/log/cron.log

COPY startup.sh /startup.sh
RUN chmod -v +x /startup.sh

CMD ["/startup.sh"]

