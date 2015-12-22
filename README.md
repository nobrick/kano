# Contribution
## Installation
Install and configure the following services:
- PostgreSQL
- Redis
- NodeJS

Run the following commands for setup:
```
bundle install
npm install
cd config
cp database.yml{.example,}
cp secrets.yml{.example,}
cp redis.yml{.example,}
cp wechat.yml{.example,}
```

Configure `database.yml` with database authentication for PostgreSQL.

To start project, ensure PostgreSQL and Redis running, then execute:
```
sidekiq
rails s
```