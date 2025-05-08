

## About this project
This project runs a php script that slacks me a reminder to walk my dog

## How to build
- Composer 2 is required to build
- From the root code directory, run

```
composer install --no-interaction --prefer-dist
cp .env.example .env
php artisan key:generate
```

## Running Tests
Once built, run `php artisan test --testdox` to test the application

## IMPORTANT
You must have the environment variable
SLACK_SECRET=

## Running the application
Simply execute `php artisan slack-me`

## Deploying the application
This application can be deployed to any environment that has PHP 8.2 CLI

## IMPORTANT
Please do not include any dev dependencies in the final build

To do this you must run composer install again with these parameters

`composer install --no-dev --optimize-autoloader`

## CI Builds
This repository has been updated to include a GitHub Action workflow to build a docker image with all development and test dependencies installed, run unit tests and then produce a production docker image that excludes the dev dependencies.

When a new tag, beginning with a `v` (e.g. `v1.0.0`) is pushed the workflow will also push the resulting image to DockerHub.

### Setup Github Variables and Secrets
Before the CI build will succeed you will need to configure two variables and one secret.  To configure these, navigate to the GitHub repository -> Settings -> Secrets and variables -> Actions. 

Once here, you will be on the Secrets tab.  Add a new secret called `DOCKERHUB_PASSWORD` and set the value to your password for DockerHub.

Next, select the Variables tab and add the following variables:

`DOCKERHUB_USERNAME` with the value set to your DockerHub username
`DOCKERHUB_REPO_NAME` with the value set to the DockerHub repository that the resulting Docker image will be pushed to

The DockerHub username and repo name are configured as varibles because they are not sensitive and by using variables we are able to see the resulting docker image tag in the bulid output.  If we configured these values as secrets they would be obfuscated in the GitHub Action build output.

## Running the Docker image
The production Docker image can be found in DockerHub here: https://hub.docker.com/repository/docker/joelweirauch/slack-me/general

The Docker image will need to have one environment variable set, `SLACK_SECRET`, and will also need to have a valid `.env` file with an environment-specific APP_KEY configured mounted when run.

The following is an example of running the `latest` tag from DockerHub using the value `foo` for the `SLACK_SECRET` environment variable and mounting an `.env.production` file from the current path to `/run/.env`:

```docker run -it --rm -e SLACK_SECRET=foo -v ./.env.production:/run/.env joelweirauch/slack-me:latest```
