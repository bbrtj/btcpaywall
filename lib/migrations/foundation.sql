-- 1 up

CREATE SEQUENCE bip44_accounts MINVALUE 0 MAXVALUE 2147483647 START 0;
CREATE SEQUENCE bip44_indexes MINVALUE 0 MAXVALUE 2147483647 START 0;

CREATE TABLE accounts (
	id uuid primary key,
	account_index INT NOT NULL DEFAULT nextval('bip44_accounts'),
	secret VARCHAR(32) NOT NULL
);

CREATE TABLE requests (
	id uuid primary key,
	account_id uuid NOT NULL,
	amount INT NOT NULL,
	derivation_index INT NOT NULL DEFAULT nextval('bip44_indexes'),
	status VARCHAR(32) NOT NULL DEFAULT 'awaiting',
	ts TIMESTAMP NOT NULL DEFAULT NOW(),
	CONSTRAINT fk_account_id
		FOREIGN KEY(account_id)
		REFERENCES accounts(id)
);

CREATE UNIQUE INDEX uniq_requests_derivation_index ON requests (derivation_index);
CREATE INDEX ind_requests_lookup ON requests (status, account_id);

CREATE TABLE request_items (
	id serial primary key,
	request_id uuid NOT NULL,
	item TEXT NOT NULL,
	CONSTRAINT fk_request_id
		FOREIGN KEY(request_id)
		REFERENCES requests(id)
);

-- 1 down

DROP TABLE requests;
DROP TABLE accounts;
DROP SEQUENCE bip44_indexes;
DROP SEQUENCE bip44_accounts;
