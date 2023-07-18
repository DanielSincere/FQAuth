# Digital Ocean Kubernetes

Deployment guide for FQAuth on Digital Ocean Kubernetes

## Pre reqs

1. A Kubernetes cluster
2. A Postgres instance, accessible from the cluster

## Install

1. Create a user in the database for FQAuth. Ensure this user has access to the `public` schema. If your user doesn't have access, login to your fqauth database as your root user and grant access. For example,

    GRANT ALL ON SCHEMA public TO fqauth;

2. Gather the other environment variables as discussed in `Sources/FQAuthServer/EnvVars.swift`, and store them in the secrets file. Rename 1-fqauth-secrets.sample.yml to 1-fqauth-secrets.yml.

  1. APPLE_APP_ID
  2. APPLE_SERVICES_KEY
  3. APPLE_SERVICES_KEY_ID
  4. APPLE_TEAM_ID
  5. AUTH_PRIVATE_KEY
  6. DB_SYMMETRIC_KEY
  7. DATABASE_URL
  8. REDIS_URL

3. Deploy the App

    kubectl apply -Rf Deploy/Kubernetes/

4. Set up ingress resources in your cluster and load balancer

5. After you login the first time, you may manually add the admin role to your user in the database, as that's not supported yet in the UI.

    UPDATE `USER` SET roles = '{"admin"}'::text[]
