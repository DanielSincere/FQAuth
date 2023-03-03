# Digital Ocean Kubernetes

Deployment guide for FQAuth on Digital Ocean Kubernetes

## Pre reqs

1. A Kubernetes cluster
2. A Postgres instance, accessible from the cluster

## Install

1. Ensure your user has access to the `public` schema. If your user doesn't have access, login to your database as your root user and grant access. For example,

    GRANT ALL ON SCHEMA public TO fqauth;

2. Deploy the in-cluster redis instance. (Out-of-cluster is fine, too, just update the environment variable to reflect this.)

    kubectl apply -f Deploy/Kubernetes/redis/fqauth-redis.yml


3. Gather the other environment variables as discussed in `Sources/FQAuthServer/EnvVars.swift`, and store them in secrets/fqauth-secrets.

  1. APPLE_APP_ID
  2. APPLE_SERVICES_KEY
  3. APPLE_SERVICES_KEY_ID
  4. APPLE_TEAM_ID
  5. AUTH_PRIVATE_KEY
  6. DB_SYMMETRIC_KEY
  7. DATABASE_URL
  8. REDIS_URL

4. Sent them up to your cluster

    kubectl apply -f Deploy/Kubernetes/secrets/fqauth-secrets

5. Deploy the App

    kubectl apply -Rf Deploy/Kubernetes/app/

6. Set up ingress resources in your cluster and Load balancer


7. After you login the first time, you may manually add the admin role to your user in the database, as that's not supported yet in the UI.

    UPDATE `USER` SET roles = '{"admin"}'::text[]
