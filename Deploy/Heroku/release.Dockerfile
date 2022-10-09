FROM ghcr.io/fullqueuedeveloper/fqauth:sha-9f33b943a946585ba449250e0f3f250482f3c623
RUN apt-get install -y curl
CMD /app/FQAuthServer migrate -y --env production
