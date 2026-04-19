import psycopg2
import os

conn = psycopg2.connect(
    database=os.getenv("DB_NAME"), 
    user=os.getenv("DB_USER"),
    password=os.getenv("DB_PASSWORD"),
    host="localhost", 
    port="5432"
    )

cur = conn.cursor()

cur.execute("""
CREATE TABLE IF NOT EXISTS users (
    id SERIAL PRIMARY KEY,
    email VARCHAR(255) UNIQUE NOT NULL,
    fullname VARCHAR(255) NOT NULL,
    dob DATE,
    phonenum VARCHAR(10),
    password_hash TEXT NOT NULL
);
""")

cur.execute("""
CREATE TABLE IF NOT EXISTS temperature (
    id SERIAL PRIMARY KEY,
    temperature FLOAT NOT NULL,
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
""")

conn.commit()
cur.close()
