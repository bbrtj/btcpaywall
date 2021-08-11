# Bitcoin payment service

## Installation

This project requires Perl 5.32 (best managed by perlbrew: https://perlbrew.pl/), PostgreSQL and bitcoind to run properly.

### bitcoind setup
1. Install bitcoind
2. Configure bitcoind for RPC. Important options are `server=1`, `rpcuser`, `rpcpassword`. You can also add `prune=1000`
3. Enable bitcoind service in your system and let it synchronize

### Code setup
1. Clone the repository
2. Add Carton to Perl: `cpan Carton`
3. Go into the repository and download the dependencies: `carton install`
4. Copy `.env.example` to `.env`. Edit database and bitcoin RPC credentials in this file.
5. Run configuration tasks:
- `carton exec script/btcpaywall migrate up` - will create required database structure.
- `carton exec script/btcpaywall generate-master-key` - will generate a new bitcoin key, which will be used to store bitcoins. Make sure to back it up and keep secure!
- `carton exec script/btcpaywall configure-node` - will generate a new bitcoind wallet and tell the node to load it on startup. This wallet does not need to be backed up, it is only necessary to watch addresses.
- `carton exec script/btcpaywall add-client <name> <callback address>` - will create a new client in the database. Clients are able to request payments, and each time a payment is complete, the callback address (URL) will be queried.
6. For production environments, make sure to set the `APP_MODE` in `.env` to `deployment`, as well as generating new `APP_SECRETS` (just google _"random sha256"_)

## Running the production application

### Perl web server

`carton exec hypnotoad script/btcpaywall` runs a standalone production web server for the application. By default, the server will listen on port 8080.

Additionally, it needs to be set behind a supervisor that will make sure it runs persistently. Use any supervisor of your choice.

See https://docs.mojolicious.org/Mojolicious/Guides/Cookbook#Hypnotoad for more info.

### Regular web server (Apache / Nginx)

Set up a web server as a proxy for Mojolicious web server. See https://docs.mojolicious.org/Mojolicious/Guides/Cookbook#Nginx or https://docs.mojolicious.org/Mojolicious/Guides/Cookbook#Apache-mod_proxy, depending on your choice.

### Firewall

Set up a firewall of your choice to hide the Perl web server port (default 8080) from outside access.

### Cron

Cron needs to be set up to run the request handling action in the background:

```
* * * * * carton exec /path/to/script/btcpaywall autoresolve
```
