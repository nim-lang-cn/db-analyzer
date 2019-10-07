DROP SCHEMA IF EXISTS qa CASCADE;
CREATE SCHEMA qa;

CREATE TABLE qa.tags (
  id                serial        NOT NULL PRIMARY KEY,
  name              varchar(255)  NOT NULL,
  question_count    int           NOT NULL
);

CREATE TABLE qa.questions (
  id                serial        NOT NULL PRIMARY KEY,
  title             varchar(255)  NOT NULL,
  content           text          NOT NULL DEFAULT '',
  created_user_id   int           NOT NULL, 
  created_username  varchar(255)  NOT NULL,
  created_date      timestamp     NOT NULL DEFAULT now(),
  is_closed         boolean       NOT NULL DEFAULT FALSE
);

CREATE TABLE qa.question_tags (
  question_id       int           NOT NULL,
  tag_id            int           NOT NULL, 
  PRIMARY KEY (question_id, tag_id) 
);