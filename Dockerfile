# Ruby 2.4 is not supported by Rails 3.2
# Upgrade after upgrading Rails.
FROM ruby:2.3.3

RUN apt-get update -qq && apt-get install -qq -y \
        build-essential \
        nodejs \
        libpq-dev \
        postgresql-client \
	vim

ENV APP_PATH /app

# Create application home and pids directory
RUN mkdir -p $APP_PATH/tmp/pids

# Set our working directory inside the image
WORKDIR $APP_PATH

COPY vendor vendor 

# Use Gemfiles as Docker cache markers before copying the rest of the app.
# We don't want to run bundler every time the source changes
COPY Gemfile Gemfile
COPY Gemfile.lock Gemfile.lock

# Prevent bundler warnings; ensure that the bundler version executed is >= that which created Gemfile.lock
RUN gem install bundler
 
# Install gems
RUN bundle install
 
# Copy the app to the workdir
COPY . .

# Forward request and error logs to stdout for docker to manage.
RUN ln -sf /dev/stdout ./log/production.log \
	&& ln -sf /dev/stdout ./log/development.log \
	&& ln -sf /dev/stdout ./log/test.log

CMD [ "config/containers/app_cmd.sh" ]
