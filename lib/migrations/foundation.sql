-- 1 up

CREATE SEQUENCE bip44_indexes MINVALUE 0 MAXVALUE 2147483647 START 0;

CREATE TABLE requests (
	id uuid primary key,
	amount INT NOT NULL,
	derivation_index INT NOT NULL DEFAULT nextval('bip44_indexes'),
	status VARCHAR(32) NOT NULL DEFAULT 'awaiting',
	ts TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE UNIQUE INDEX uniq_requests_derivation_index ON requests (derivation_index);
CREATE INDEX ind_requests_status ON requests (status);

-- 1 down

DROP TABLE requests;
