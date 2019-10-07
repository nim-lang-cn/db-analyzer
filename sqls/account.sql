DROP SCHEMA IF EXISTS account CASCADE;
CREATE SCHEMA account;

CREATE TYPE  account.gender AS ENUM(
  'UNKNOWN', 'FEMALE', 'MALE'
);

CREATE TABLE account.users (
  id            serial          NOT NULL PRIMARY KEY,
  username      varchar(255)    NOT NULL,
  password      char(64)        NOT NULL,
  phone         varchar(255)    NOT NULL,
  email         varchar(255)    DEFAULT NULL,
  gender        account.gender  NOT NULL DEFAULT 'UNKNOWN',
  created_date  timestamp       NOT NULL,
  is_active     boolean         NOT NULL DEFAULT TRUE
);