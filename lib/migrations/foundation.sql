-- 1 up

CREATE TABLE requests (
	id uuid primary key,
	amount INT NOT NULL,
	derivation_index INT NOT NULL,
	status INT NOT NULL DEFAULT 1,
	ts TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE UNIQUE INDEX uniq_requests_derivation_index ON requests (derivation_index);
CREATE INDEX ind_requests_status ON requests (status);

-- 1 down

DROP TABLE requests;
