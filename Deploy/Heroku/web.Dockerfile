FROM ghcr.io/fullqueuedeveloper/fqauth:sha-beb6aad21ad1a99e4525ee2d6a382ba0556f222b
ENV PORT 80
EXPOSE $PORT
CMD /app/FQAuthServer serve --env production --hostname 0.0.0.0 -p $PORT
