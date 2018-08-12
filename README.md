# ynabsync

Tool to sync SBanken accounts with YNAB.

The application consists of 4 parts:

1. Scheduler - enqueues sidekiq jobs at a specified interval
2. Worker - consumes sidekiq jobs and performs the heavy lifting
3. Web UI - to debug the jobs
4. Redis

## Installation

You need `direnv`, `docker` and `docker-compose` to run the application.

Copy `.envrc.example` to `.envrc` and setup the environment variables:

| Environment variable | Description                                                                                                      |
| -------------------- | ---------------------------------------------------------------------------------------------------------------- |
| `SBANKEN_APP_ID`     | The client ID from SBanken Developer Portal                                                                      |
| `SBANKEN_SECRET`     | The secret key/password from SBanken Developer Portal (please note that this key must be rotated every 3 months) |
| `CUSTOMER_ID`        | Your personal number (personnummer) for identification with the SBanken API                                      |
| `ACCOUNT_ID`         | The account ID from SBanken API for the account you'd like to monitor.                                           |
| `YNAB_ACCESS_TOKEN`  | Personal YNAB access token ([generated here](https://app.youneedabudget.com/settings/developer))                 |
| `YNAB_BUDGET_ID`     | The budget ID from YNAB                                                                                          |
| `YNAB_ACCOUNT_ID`    | The account ID from YNAB                                                                                         |
| `KEMAL_PASSWORD`     | Password to access the web ui                                                                                    |

## Usage

1. Run `docker-compose up`
2. Open [http://localhost:3000/](http://localhost:3000/) to see the queue status

## Development

TODO: Write development instructions here

## Contributing

1. Fork it (<https://github.com/theodorton/ynabsync/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [theodorton](https://github.com/theodorton) Theodor Tonum - creator, maintainer
