# Start with a build container for running the build and tests
FROM composer:2 AS builder

WORKDIR /build

# Add all of the application files to the build directory
ADD . /build

# Install dependencies and setup the environment to run unit tests
RUN composer install --no-interaction --prefer-dist
RUN cp .env.example .env
RUN php artisan key:generate

# Use a build arg to pass a secret via the environment
# We could also use an ENV or ARG in the Dockerfile but
# I feel that leaves too much opportunity for someone to
# accidentally commit a secret by mistake. Also, docker will
# throw a warning about secrets in the Dockerfile if we were to
# provide a dummy value in an ENV or ARG
RUN SLACK_SECRET=${SLACK_SECRET} php artisan test --testdox

# Re-run composer to remove dev dependencies and optimize the autoloader
# We do this in the build step so we don't require or generate extra, 
# unnecessary files in the final container.
RUN composer install --no-dev --optimize-autoloader

# Switch to a new image for the final production container
FROM php:8.2-cli

WORKDIR /run

# We will copy only the necessary files and directories
# into the final image.  We will especially ensure that we
# don't copy the .env file or any other sensitive files/directories
# into the final image.
COPY --from=builder /build/app app
COPY --from=builder /build/bootstrap bootstrap
COPY --from=builder /build/config config
COPY --from=builder /build/database database
COPY --from=builder /build/public public
COPY --from=builder /build/resources resources
COPY --from=builder /build/routes routes
COPY --from=builder /build/storage storage
COPY --from=builder /build/vendor vendor
COPY --from=builder /build/artisan artisan
COPY --from=builder /build/composer.json composer.json

# Switch to a non-root user for the runtime
USER www-data

# Set the default command so it doesn't need to be passed
# when running a container.
CMD ["php", "artisan", "slack-me"]
