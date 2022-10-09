# Heroku Deployment Guide

## Prereqs

Install heroku cli tool from Homebrew

## Setup.

1. Create a Heroku account
2. Create an app on Heroku, perhaps named "fqauth-server-{name}"
3. Provision this app with a Postgres DB and a Redis DB
4. Clone the FQAuth repo to your local computer
5. Choose container stack `heroku  stack:set -a fqauth-server-{name} container`
6. Setup heroku remote `heroku git:remote -a fqauth-server-{name}`
