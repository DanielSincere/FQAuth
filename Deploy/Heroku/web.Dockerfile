FROM ghcr.io/fullqueuedeveloper/fqauth:sha-9f33b943a946585ba449250e0f3f250482f3c623
RUN sudo apt-get update && apt-get install -y curl
ENV PORT 80
EXPOSE $PORT
CMD /app/FQAuthServer serve --env production --hostname 0.0.0.0 -p $PORT
