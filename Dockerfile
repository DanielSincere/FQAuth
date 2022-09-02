FROM index.docker.io/library/swift:5.6-focal as builder
WORKDIR /src
COPY ./Package.* ./
COPY ./Sources ./Sources
COPY ./Resources ./Resources
COPY ./Tests ./Tests
RUN swift build -c release -Xswiftc -g
RUN mkdir /output
RUN cp $(swift build -c release -Xswiftc -g --show-bin-path)/fqauth-server /output/fqauth-server
RUN cp -R ./Resources /output/Resources

FROM index.docker.io/library/swift:5.6-focal-slim as prod_base
RUN useradd --user-group --create-home --system --skel /dev/null --home-dir /app vapor
WORKDIR /app
COPY --from=builder --chown=vapor:vapor /output/* /app
COPY --from=builder /usr/lib/swift/ /usr/lib/swift/
USER vapor:vapor

FROM prod-base as web
ENV PORT 80
EXPOSE $PORT
CMD /app/fqauth-server serve --env production --hostname 0.0.0.0 -p $PORT

FROM prod-base as worker
CMD /app/fqauth-server queues --env production

FROM prod-base as scheduled-worker
CMD /app/fqauth-server queues --scheduled --env production
