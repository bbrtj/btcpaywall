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
