-- 1 up

CREATE TABLE accounts (
	id uuid primary key,
	acc_key VARCHAR(255) NOT NULL,
	ver_key VARCHAR(255) NOT NULL,
	ver_key_number INT NOT NULL
);

CREATE TABLE goals (
	id uuid primary key,
	account_id uuid,
	hrid VARCHAR(64),
	key_number INT,
	title TEXT,
	content TEXT,
	CONSTRAINT fk_account_id
		FOREIGN KEY(account_id)
		REFERENCES accounts(id)
);

-- 1 down

DROP TABLE goals;
DROP TABLE accounts;

-- 2 up

CREATE TABLE requests (
	id uuid primary key,
	status INT NOT NULL DEFAULT 1,
	ts TIMESTAMP NOT NULL
);

CREATE TABLE actions (
	id uuid primary key,
	request_id uuid,
	type VARCHAR(64) NOT NULL,
	data json,
	CONSTRAINT fk_request_id
		FOREIGN KEY(request_id)
		REFERENCES requests(id)
);

CREATE INDEX ind_actions_lookup ON actions (request_id);

-- 2 down

DROP TABLE actions;
DROP TABLE requests;

