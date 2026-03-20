import os
from openai import OpenAI

def main():
    # Make sure your API key is set as an environment variable:
    # export OPENAI_API_KEY="your_api_key_here"
    api_key = os.getenv("OPENAI_API_KEY")
    #api_key="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"
    if not api_key:
        print("❌ No API key found. Please set the OPENAI_API_KEY environment variable.")
        return

    client = OpenAI(api_key=api_key)


    try:
        response = client.chat.completions.create(
            model="gpt-4.1-mini",  # You can switch to "gpt-4.1" or others
            messages=[
                {"role": "system", "content": "You are a helpful assistant."}
                #{"role": "user", "content": "Say hello! This is just a test."}
            ]
        )

        print("✅ API request successful!")
        print("Response:", response.choices[0].message.content)

    except Exception as e:
        print("❌ Error:", str(e))

if __name__ == "__main__":
    main()
