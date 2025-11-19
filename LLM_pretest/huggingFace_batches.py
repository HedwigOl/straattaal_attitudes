import pandas as pd
import os
from transformers import pipeline, AutoTokenizer

def run_experiment(model_name: str, prompts_path: str, temperature: float = 0.7,
                   answer_length: int = 200, batch_size: int = 8 ):
    """
    Run the full experiment and add response to the output csv.
    """
    # Setup paths
    script_dir = os.path.dirname(os.path.abspath(__file__))
    os.environ["HF_HOME"] = f"{script_dir}/hug_models"
    os.environ["HF_HUB_OFFLINE"] = "1"

    # Load prompts from csv file
    df = pd.read_csv(prompts_path, sep="\t").reset_index(drop=True)

    # Add the response column
    if "response" not in df.columns:
        df["response"] = None

    # Prepare output directory
    model_safename   = model_name.replace("/", "_")
    output_directory = os.path.join(script_dir, f"output_{model_safename}")
    os.makedirs(output_directory, exist_ok=True)
    prompt_base = os.path.splitext(os.path.basename(prompts_path))[0]

    tokenizer = AutoTokenizer.from_pretrained(model_name, padding_side="left")

    pipe = pipeline(
        "text-generation",
        model=model_name,
        tokenizer=tokenizer,
        max_new_tokens=answer_length,
        temperature=temperature,
        do_sample=True,
        device=0 
    )

    # Process prompts in batches
    total = len(df)
    prompts = df["prompt"].tolist()

    for start in range(0, total, batch_size):
        end = min(start + batch_size, total)
        batch = prompts[start:end]

        messages = [[{"role": "user", "content": p}] for p in batch]

        try:
            results = pipe(messages, batch_size=batch_size)

            for index, result in enumerate(results):
                try:
                    df.at[start + index, "response"] = result[0]["generated_text"][1]["content"]
                except:
                    df.at[start + index, "response"] = "ERROR: incorrect response format"

        except Exception as e:
            for i in range(start, end):
                df.at[i, "response"] = f"ERROR: {e}"

        # Print progress
        print(f"Processed {end}/{total} prompts", flush=True)

    # Save results to output file
    out_path = os.path.join(output_directory, f"{model_safename}_{prompt_base}_responses.csv")
    df.to_csv(out_path, sep="\t", index=False)

    print(f"\nDone. Saved output to: {out_path}")
