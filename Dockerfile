FROM ruby:3.3.1

# Install dependencies
RUN apt-get update -qq && apt-get install -y apt-utils build-essential libpq-dev curl

# Install Node.js
RUN curl -fsSL https://deb.nodesource.com/setup_current.x | bash - && \
    apt-get install -y nodejs

# Setup work directory
RUN mkdir /repo
WORKDIR /repo

# Install Ruby and Node.js dependencies
COPY Gemfile /repo/Gemfile
COPY Gemfile.lock /repo/Gemfile.lock

RUN bundle update --bundler && gem update --system && bundle install

# Before `npm install`, to leverage Docker caching
COPY package.json package-lock.json* /repo/
RUN npm install

# Copy the rest of the application code
COPY . /repo

# Set the environment variable for OpenSSL legacy support
ENV NODE_OPTIONS=--openssl-legacy-provider

RUN bundle exec rake assets:precompile

# Add and prepare startup script
COPY startup.sh /repo/startup.sh
RUN chmod +x /repo/startup.sh

EXPOSE 3000

ENTRYPOINT ["/repo/startup.sh"]
