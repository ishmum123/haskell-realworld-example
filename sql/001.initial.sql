CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

CREATE TABLE IF NOT EXISTS users (
    id SERIAL PRIMARY KEY
  , email VARCHAR(64) UNIQUE NOT NULL
  , username VARCHAR(64) UNIQUE NOT NULL
  , password VARCHAR(60) NOT NULL
  , bio TEXT
  , image TEXT
  , created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
  , updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS follows (
    user_id INTEGER
  , follows_user_id INTEGER
  , created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
  , updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP

  , FOREIGN KEY (user_id) REFERENCES users (id)
  , FOREIGN KEY (follows_user_id) REFERENCES users (id)
  , UNIQUE (user_id, follows_user_id)
);

CREATE TABLE IF NOT EXISTS articles (
    id SERIAL PRIMARY KEY
  , slug VARCHAR(256) UNIQUE NOT NULL
  , title VARCHAR(256) NOT NULL
  , description VARCHAR(256) NOT NULL
  , body TEXT NOT NULL
  , created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
  , updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
  , user_id INTEGER NOT NULL

  , FOREIGN KEY (user_id) REFERENCES users (id)
);

CREATE TABLE IF NOT EXISTS tags (
    id SERIAL PRIMARY KEY
  , text VARCHAR(32) UNIQUE
  , created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
  , updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS tagged (
    article_id INTEGER
  , tag_id INTEGER
  , created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
  , updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP

  , FOREIGN KEY (tag_id) REFERENCES tags (id)
  , FOREIGN KEY (article_id) REFERENCES articles (id)
  , UNIQUE (tag_id, article_id)
);

CREATE TABLE IF NOT EXISTS favorited (
    user_id INTEGER
  , article_id INTEGER
  , created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
  , updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP

  , FOREIGN KEY (user_id) REFERENCES users (id)
  , FOREIGN KEY (article_id) REFERENCES articles (id)
  , UNIQUE (user_id, article_id)
);

CREATE TABLE IF NOT EXISTS comments (
    id SERIAL PRIMARY KEY
  , uuid UUID UNIQUE DEFAULT uuid_generate_v4()
  , body TEXT
  , created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
  , updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
  , article_id INTEGER
  , user_id INTEGER

  , FOREIGN KEY (article_id) REFERENCES articles (id)
  , FOREIGN KEY (user_id) REFERENCES users (id)
);
