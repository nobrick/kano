# Kano
[![Circle CI](https://circleci.com/gh/nobrick/kano.svg?style=svg&circle-token=524e74c362b8210de373f211ff35129cfaaf7a7a)](https://circleci.com/gh/nobrick/kano)

## Installation for Development
Install and configure the following packages:
- PostgreSQL
- Redis
- NodeJS
- ImageMagick

Run the following commands for setup:
```
bundle install
npm install
cd config
cp database.yml{.example,}
cp secrets.yml{.example,}
cp redis.yml{.example,}
cp wechat.yml{.example,}
cp handyman_wechat.yml{.example,}
cp sms.yml{.example,}
cp slack.yml{.example,}
```

Configure `database.yml` with database authentication for PostgreSQL.

To start project, ensure PostgreSQL and Redis running, then execute:
```
sidekiq
rails s
```

## Contribution
Check [CONTRIBUTING.md](https://github.com/nobrick/kano/blob/master/CONTRIBUTING.md) for contribution guidelines.
