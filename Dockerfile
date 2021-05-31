FROM ruby:3.0.1-slim-buster

ENV DOCKERIZE_VERSION 0.6.1

# Install PG dependencies
RUN apt-get update \
  && apt-get install -qq -y --no-install-recommends \
    build-essential \
    curl \
    git-core \
    libpq-dev

# Install Dockerize
RUN curl -L https://github.com/jwilder/dockerize/releases/download/v$DOCKERIZE_VERSION/dockerize-linux-amd64-v$DOCKERIZE_VERSION.tar.gz | tar xz && mv dockerize /usr/bin/

# Expose port 3000 to the Docker host
EXPOSE 3000

# An entrypoint to run migrations and so on
COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
RUN chmod +x /usr/local/bin/docker-entrypoint.sh
ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]

# The main command to start the server
CMD ["bundle exec rails server -p 3000 -b 0.0.0.0"]
