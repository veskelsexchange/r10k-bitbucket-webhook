FROM ruby:2.6-slim

# # Environment Variables for Sinatra

# RUNMODE controls Debug/Production Settings
ENV RUNMODE="development"

# LISTEN controls the Listening IP Address
ENV HOST="127.0.0.1"

# Add Puppet Bolt repo
RUN apt-get update
RUN apt-get install -y wget
RUN wget https://apt.puppet.com/puppet-tools-release-buster.deb
RUN dpkg -i puppet-tools-release-buster.deb
RUN apt-get update
RUN apt-get install -y puppet-bolt

# Disabling Analytics for Bolt
RUN mkdir -p /root/.puppetlabs/bolt
RUN echo "disabled: true" > /root/.puppetlabs/bolt/analytics.yaml

# Install BeanstalkD
RUN apt-get install -y beanstalkd

# Install Supervisor D
RUN apt-get install -y supervisor

# Install Supervisor D Configuration
COPY ./supervisor.conf /etc/supervisor/conf.d/supervisor.conf

# Install Gems
RUN mkdir /gems
COPY ./gems/Gemfile /gems/Gemfile
COPY ./rackup.sh /rackup.sh
RUN chmod +x /rackup.sh

RUN cd /gems/ && bundle install
RUN chmod 0755 /usr/local/bundle

# Mountpoint for web directory
RUN mkdir /web/

# Mountpoint for worker directory
RUN mkdir /worker/

# Make SSH key for use later. Print public portion for use in Puppet masters
RUN mkdir -m 700 /root/.ssh/
RUN ssh-keygen -t rsa -b 4096 -f /root/.ssh/id_rsa -P "" && \
                        echo "\e[1m \033[32m PLEASE COPY THIS KEY IF YOU DONT INTEND TO USE YOUR OWN \033[39m" && \
                        echo "" && \
                        cat /root/.ssh/id_rsa.pub && echo '\e[0m'

ENTRYPOINT [ "supervisord", "-n" ]
