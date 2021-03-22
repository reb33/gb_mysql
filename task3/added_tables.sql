DROP TABLE IF EXISTS relationships;
DROP TABLE IF EXISTS relationships_types;
CREATE TABLE relationships_types (
	id TINYINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
    description VARCHAR(100) NOT NULL
);

CREATE TABLE relationships (
	id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
    from_user_id BIGINT UNSIGNED NOT NULL ,
    to_user_id BIGINT UNSIGNED NOT NULL,
    relation_type_id TINYINT UNSIGNED NOT NULL,
    updated_at DATETIME ON UPDATE CURRENT_TIMESTAMP,

    FOREIGN KEY (from_user_id) REFERENCES users(id),
    FOREIGN KEY (to_user_id) REFERENCES users(id),
    FOREIGN KEY (relation_type_id) REFERENCES relationships_types(id)
);

DROP TABLE IF EXISTS documents;
DROP TABLE IF EXISTS documents_types;
CREATE TABLE documents_types(
    id TINYINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
    description VARCHAR(100) NOT NULL
);

CREATE TABLE documents (
	id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
	user_id BIGINT UNSIGNED NOT NULL,
    doc_type_id TINYINT UNSIGNED NOT NULL,
    doc_serial VARCHAR(100),
    doc_number VARCHAR(100),
    date_issue DATETIME,
    created_at DATETIME DEFAULT NOW(),
    updated_at DATETIME ON UPDATE CURRENT_TIMESTAMP,

    FOREIGN KEY (user_id) REFERENCES users(id),
    FOREIGN KEY (doc_type_id) REFERENCES documents_types(id),
    INDEX doc_number(doc_number),
    INDEX doc_serial_number(doc_serial, doc_number)
);

DROP TABLE IF EXISTS tags_message;
DROP TABLE IF EXISTS tags;
CREATE TABLE tags(
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
    `desc` VARCHAR(100) NOT NULL,

    INDEX tag(`desc`)
);

CREATE TABLE tags_message(
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
    `desc` VARCHAR(100) NOT NULL,
    tag_id BIGINT UNSIGNED NOT NULL,
    message_id BIGINT UNSIGNED NOT NULL,

    FOREIGN KEY (tag_id) REFERENCES tags(id),
    FOREIGN KEY (message_id) REFERENCES messages(id),
    INDEX tag(`desc`)
);
