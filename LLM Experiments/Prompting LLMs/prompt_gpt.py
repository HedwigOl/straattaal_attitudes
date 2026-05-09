import os
import pandas as pd
from openai import OpenAI

def run_experiment(model_name: str, prompts_path: str, answer_length=100, batch_size=8, temperature=0.001, it=2):
    #Setup paths
    script_dir = os.path.dirname(os.path.abspath(__file__))

    # Load prompts CSV
    df = pd.read_csv(prompts_path, sep=";").reset_index(drop=True)

    # Ensure response column exists
    if "response" not in df.columns:
        df["response"] = None

    # Prepare output directory
    model_safename = model_name.replace("/", "_")
    output_directory = os.path.join(script_dir, f"output_{model_safename}")
    os.makedirs(output_directory, exist_ok=True)

    prompt_base = os.path.splitext(os.path.basename(prompts_path))[0]
    out_path    = os.path.join(output_directory, f"{model_safename}_{prompt_base}_responses_{temperature}_{it}.csv")

    # Process prompts in batches
    total = len(df)
    prompts = df["prompt"].tolist()

    for start in range(0, total, batch_size):
        end = min(start + batch_size, total)
        batch = prompts[start:end]

        for index, prompt in enumerate(batch):
            try:
                response = client.responses.create(
                    model = model_name,
                    input = prompt,
                    temperature = temperature,
                    max_output_tokens = answer_length,
                    reasoning = { "effort" : "none" }
                )

                # Extract response
                try:
                    df.at[start + index, "response"] = response.output_text
                except (AttributeError, IndexError):
                    df.at[start + index, "response"] = "ERROR: incorrect response format"

            except Exception as e:
                df.at[start + index, "response"] = f"ERROR: {str(e)}"

         # Save every 100 responses
        if end % 100 == 0 or end == total:
            df.to_csv(out_path, sep="\t", index=False)

        print(f"Processed {end}/{total} prompts", flush=True)

    print(f"\nDone. Saved output to: {out_path}")

