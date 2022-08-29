# FQAuth

## Goals
From a user perspective, you could deploy this microservice to a heroku freetier replacement while your main app runs on different provider. Or include in your kubernetes deployment behind your load balancer. Ease of deployment for newcomers to DevOps is a priority.

## How
I stream my contributions, which would include code, codereviews, writing tickets, and diagrams. My twitch username is [FullQueueDeveloper](https://twitch.tv/FullQueueDeveloper) & link is in my profile

## Main flow:
Receive a login request and return an JWT that can be exchanged for a session JWT. Both of these are returned on an initial request. The JWT contains the roles that user is authorized for, stored in Postgres

Looking to support Sign in with Apple and Sign in with Google to start, since those are the two biggest mobile OS's at the moment. Support login from an iOS/Mac/Android app as well as a website.

Other features
- Apple server notifications
- Google equivalent (if available)
- unit tests
- Vapor queues to run cleanup tasks, or ping apple
Future maybes handle in app purchases as well? Since mostlikely, we would want the JWT to include the current subscription tiers.

## Build targets:
- Docker container
- Helm chart
- Vapor SDK for other microservices to consume the JWTs (optional)
- iOS client SDK (optional)
- Android client SDK (optional)
- JS SDK (optional)

## Infrastructure:
- Postgres
- Redis (maybe)

## Sponsors

If you learn anything or make a few bucks from this repo, please sponsor me on GitHub. https://github.com/sponsors/FullQueueDeveloper/

A huge thank you to the following for keeping the dream alive! 💜🗽

1. [0xLeif](https://github.com/0xLeif)


## License:
MIT or equivalent
