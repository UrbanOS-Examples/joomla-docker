FROM ubuntu:latest

# Create the log file to be able to run tail
RUN touch /var/log/cron.log

#Install Cron
RUN apt-get update
RUN apt-get -y install cron -y
RUN apt-get install wget -y
RUN apt-get install python -y

# Run the command on container startup
CMD cron && tail -f /var/log/cron.log
