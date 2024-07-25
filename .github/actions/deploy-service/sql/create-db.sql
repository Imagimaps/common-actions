IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = :db_name)
BEGIN
  CREATE DATABASE :db_name;
END
