CREATE TABLE my_wish_list (
  id INTEGER NOT NULL PRIMARY KEY,
  item TEXT NOT NULL,
  image TEXT
);

CREATE TABLE friends_wish_list (
  id INTEGER NOT NULL PRIMARY KEY,
  checkbox INTEGER DEFAULT 0 NOT NULL, 
  item TEXT NOT NULL,
  image TEXT
);