# Bitcoin payment service

## What is it?
It is a standalone payment server that uses a local Bitcoin node to check the balance of the payment address. It accepts payment requests from one or more sources, shows paywalls to end users and notifies callback addresses of successful payments.

## Features
- Uses no third party services
- Can work on a pruned node, which only takes a couple gigabytes of space
- Uses Segregated Witness addresses `P2WPKH` natively, but can also accept compatibility SegWit addresses `P2SH(P2WPKH)`
- BIP44 compilant, any BIP44 wallet can be used to withdraw payments

## How it works?

### Client accounts
Each service that is going to be allowed to request a payment through the server must first be added to the database with a command:
```
carton exec script/btcpaywall add-client <name> <callback address>
```

Where:
- `<name>` is a human-readable name of the client, that will be shown on payment pages to help end users identify the transaction
- `<callback address>` is a full URL to a resource that will be used to notify the service back after the payment is complete. This resource must respond with HTTP 2XX status for payment to be marked as complete.

Each service registered as a client must keep track of who bought what. After the payment is complete and the callback resource responded with HTTP 2XX status, the job of the paywall system is done.

### Payment requests
The payment server accepts payment requests through an API call. For a request to be validated, it much identify itself as one of the clients present in the server's database.

A payment request has a lifetime of 14 days and can end up in a couple of states:

```
            ┌─> pending ──┬────────────────────┐
awaiting ───┤             └─> callback_failed ─┴─> complete
            └─> timeout
```

- `awaiting` - the request has been created and the node is watching the payment address in the blockchain.
- `pending` - a sufficient value in Bitcoin has been sent to the address, but is not yet confirmed in the blockchain.
- `complete` - the payment has been completed and the callback address was successfully queried.
- `timeout` - there was no payment in the blockchain for two weeks. The system has stopped watching the associated address.
- `callback_failed` - the payment was successful, but the callback address does not return the expected status code. The system will keep querying the callback until returns HTTP 2XX.

The client service only gets notified of `awaiting` and `complete` states.

#### Payment request API

The `POST /request/new` action can be called by a client in order to create a new payment request. The body of this request should be JSON encoded object with following keys:

```
{
	"account_id": string,
	"amount": integer,
	"items": array,
	"ts": integer,
	"hash": string
}
```

Where:
- `account_id` - identifier of client that is requesting the payment
- `amount` - natual number - requested amount in Satoshi, greater than the network minimum which is 5460
- `items` - an array of strings, where each string is a human readable name of a thing the user is buying. Shown on the payment page
- `ts` - unix timestamp of the operation. Will only be valid for the next five minutes
- `hash` - sha256 token authorizing the operation (see `Client authentication` below)

The response of this action will be a JSON encoded object with following keys:

```
{
	"status": boolean,
	"data": string|array
}
```

Where `data` will contain the new request ID if the status is `true`, or an array of request errors if the status is `false`.

### Client authentication
Once the client account is created, the secret key must be used to create hash tokens for payment request creation API. The procedure to create a valid hash is as follows:

```
hash = sha256(account_id ~ amount ~ (items[0] ~ ... ~ items[n]) ~ ts ~ secret)
```

Where the `~` infix operator joins the strings with two characters `//` in between them. The output should be encoded as a hexadecimal number.

### Server authentication
Once the payment is done, the payment server will run a POST request to an URL provided during account creation. This callback contains a JSON encoded object in its body, with a hash token much like the one in the previous section. The object contains the following keys:

```
{
	"account_id": string,
	"request_id": string,
	"ts": integer,
	"hash": string
}
```

Where:
- `account_id` - identifier of the client account. Should match your own client account
- `request_id` - identifier of the request, previously returned from the request creation action
- `ts` - unix timestamp of the request time. Should be checked against current timestamp with a fitting time window (like 5 minutes)
- `hash` - sha256 token authorizing the operation, obtained with the procedure:

```
hash = sha256(account_id ~ request_id ~ ts ~ secret)
```

Where the `~` infix operator joins the strings with two characters `//` in between them. The output should be encoded as a hexadecimal number.

After checking that all the data is valid, and that the hash created using client's secret matches, the given `request_id` should be marked as paid for, and proper resources should be granted to the user who is associated with that request. HTTP 2XX status should be returned from the action, to prevent the payment server from querying the callback URL. Returning anything else than HTTP 2XX will cause the payment server to retry the request every minute.

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
