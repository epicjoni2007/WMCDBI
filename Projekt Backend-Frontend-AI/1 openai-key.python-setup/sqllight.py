import sqlite3

conn = sqlite3.connect("responses.db")
cur = conn.cursor()
cur.execute("SELECT id, prompt, response, created_at FROM responses")
rows = cur.fetchall()
for row in rows:
    print(row)
conn.close()
