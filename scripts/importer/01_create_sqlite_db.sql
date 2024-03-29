CREATE TABLE urls
(
    keyword     varchar PRIMARY KEY NOT NULL DEFAULT '',
    url         text                NOT NULL,
    title       text                         DEFAULT NULL,
    timestamp   datetime            NOT NULL DEFAULT CURRENT_TIMESTAMP,
    ip          varchar             NOT NULL,
    clicks      int UNSIGNED        NOT NULL,
    is_dead     boolean                      DEFAULT NULL,
    is_imported boolean             NOT NULL DEFAULT false
);