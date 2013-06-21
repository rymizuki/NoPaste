SET NAMES 'utf8';

CREATE TABLE paste (
  pkey        INT UNSIGNED  NOT NULL AUTO_INCREMENT,
  id          VARCHAR(64)   NOT NULL,
  id_hash     INT UNSIGNED  NOT NULL,
  subject     VARCHAR(64)             DEFAULT NULL,
  body        TEXT          NOT NULL,
  created_at  DATETIME      NOT NULL,
  updated_at  TIMESTAMP     NOT NULL,
  PRIMARY KEY pkey (pkey),
  UNIQUE id(id, id_hash),
  INDEX created_at(created_at)
)ENGINE=InnoDB DEFAULT charset='utf8';
