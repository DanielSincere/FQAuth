# Heroku Deployment Guide

## Prereqs

Install heroku cli tool from Homebrew

## Setup.

1. Create a Heroku account
2. Create an app on Heroku, perhaps named "fqauth-server-{name}"
3. Provision this app with a Postgres DB and a Redis DB
4. Set config variables in Heroku's web portal or thru the command line
  - `AUTH_PRIVATE_KEY`: output of `swish generate-jwt-key`
  - `DB_SYMMETRIC_KEY`: output of `swish generate-db-key`
  - `APPLE_SERVICES_KEY`: set this up in App Store Connect
  - `APPLE_SERVICES_KEY_ID`: ID of the key in App Store Connect
  - `APPLE_TEAM_ID`: your Apple team ID. Looks like `ARST1234`
  - `APPLE_APP_ID`: the bundle ID of your app
4. Clone the FQAuth repo to your local computer
5. Choose container stack `heroku  stack:set -a fqauth-server-{name} container`
6. Setup heroku remote `heroku git:remote -a fqauth-server-{name}`
7. Push to heroku `git push heroku trunk:main`
