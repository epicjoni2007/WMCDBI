import os
import sys
import sqlite3
from datetime import datetime
from openai import OpenAI

DB_FILE = "responses.db"

def setup_db():
    """Create a SQLite table if it doesn’t exist."""
    conn = sqlite3.connect(DB_FILE)
    cur = conn.cursor()
    cur.execute("""
        CREATE TABLE IF NOT EXISTS responses (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            prompt TEXT NOT NULL,
            response TEXT NOT NULL,
            created_at TEXT NOT NULL
        )
    """)
    conn.commit()
    conn.close()

def save_response(prompt, response):
    """Insert a row into the DB."""
    conn = sqlite3.connect(DB_FILE)
    cur = conn.cursor()
    cur.execute(
        "INSERT INTO responses (prompt, response, created_at) VALUES (?, ?, ?)",
        (prompt, response, datetime.utcnow().isoformat())
    )
    conn.commit()
    conn.close()

def fetch_responses():
    """Read back stored responses."""
    conn = sqlite3.connect(DB_FILE)
    cur = conn.cursor()
    cur.execute("SELECT id, prompt, response, created_at FROM responses ORDER BY id DESC")
    rows = cur.fetchall()
    conn.close()
    return rows

def main():
    setup_db()

    api_key = os.getenv("OPENAI_API_KEY")
    if not api_key:
        print("❌ Please set OPENAI_API_KEY")
        sys.exit(1)

    client = OpenAI(timeout=10.0, max_retries=0)

    prompt = "What is the meaning of an LIVE"
    try:
        r = client.responses.create(
            model="gpt-4o-mini",
            input=prompt,
            timeout=15.0
        )
        output = r.output_text
        print("✅ Got response:", output)

        # Save to DB
        save_response(prompt, output)

        # Show last 5 entries
        print("\n📜 Last stored responses:")
        for row in fetch_responses()[:5]:
            print(f"[{row[0]}] {row[3]} | Prompt: {row[1]} | Response: {row[2]}")

    except Exception as e:
        print("❌ Error:", e)

if __name__ == "__main__":
    main()
