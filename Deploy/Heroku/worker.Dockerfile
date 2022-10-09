FROM ghcr.io/fullqueuedeveloper/fqauth:sha-beb6aad21ad1a99e4525ee2d6a382ba0556f222b
CMD /app/FQAuthServer queues --env production
