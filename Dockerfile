FROM phusion/passenger-ruby22:0.9.15

# Set correct environment variables.
ENV HOME /root
ENV APP_HOME /home/app/webapp

# Use baseimage-docker's init system.
CMD ["/sbin/my_init"]

# Run Bundle in a cache efficient way
VOLUME /tmp/bundle
WORKDIR /tmp/bundle
ADD Gemfile /tmp/bundle/
ADD Gemfile.lock /tmp/bundle/
RUN bundle install --jobs 4 --retry 6 --deployment --without development test

# Install bower
RUN npm -g install bower@1.7.9

# Run bower in a cache efficient way
WORKDIR /home/app/webapp/
ADD .bowerrc /home/app/webapp/
ADD bower.json /home/app/webapp/
RUN bower install --allow-root

# Config nginx
RUN rm -f /etc/service/nginx/down && \
    rm /etc/nginx/sites-enabled/default
ADD nginx.conf /etc/nginx/sites-enabled/webapp.conf

# Build web application
ADD . /home/app/webapp/
VOLUME /home/app/webapp/public/system
RUN bundle exec rake assets:precompile

# Change /home/app/webapp owner to user app
RUN sudo chown -R app:app /home/app/webapp/

# Clean up APT when done
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/[!bundle]* /var/tmp/*