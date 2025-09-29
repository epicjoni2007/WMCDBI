import os
from openai import OpenAI

def main():
    # Make sure your API key is set as an environment variable:
    # export OPENAI_API_KEY="your_api_key_here"
    api_key = os.getenv("OPENAI_API_KEY")
    # OPENAI_API_KEY=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
    if not api_key:
        print("❌ No API key found. Please set the OPENAI_API_KEY environment variable.")
        return

    client = OpenAI(api_key=api_key)

    try:
        response = client.chat.completions.create(
            model="gpt-4.1-mini",  # You can switch to "gpt-4.1" or others
            messages=[
                {"role": "system", "content": "You are a helpful assistant."},
                {"role": "user", "content": "Say hello! This is just a test."}
            ]
        )

        print("✅ API request successful!")
        print("Response:", response.choices[0].message.content)

    except Exception as e:
        print("❌ Error:", str(e))

if __name__ == "__main__":
    main()
