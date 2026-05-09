import pandas as pd
import os
import torch
from transformers import pipeline, AutoTokenizer

def run_experiment(model_name: str, prompts_path: str, temperature: float,
                   answer_length: int, batch_size: int):

    script_dir = os.path.dirname(os.path.abspath(__file__))
    os.environ["HF_HOME"] = f"{script_dir}/hug_models"
    os.environ["HF_HUB_OFFLINE"] = "1"

    df = pd.read_csv(prompts_path, sep=",").reset_index(drop=True)

    if "response" not in df.columns:
        df["response"] = None

    model_safename   = model_name.replace("/", "_")
    output_directory = os.path.join(script_dir, f"output_{model_safename}")
    os.makedirs(output_directory, exist_ok=True)
    prompt_base = os.path.splitext(os.path.basename(prompts_path))[0]
    out_path = os.path.join(output_directory, f"{model_safename}_{prompt_base}_{str(temperature)}_responses.csv")

    tokenizer = AutoTokenizer.from_pretrained(model_name, padding_side="left")
    tokenizer.pad_token = tokenizer.eos_token

    pipe = pipeline(
        "text-generation",
        model=model_name,
        tokenizer=tokenizer,
        max_new_tokens=answer_length,
        temperature=temperature,
        device=0
    )

    total = len(df)
    prompts = df["prompt"].tolist()

    for start in range(0, toal, batch_size):
        end = min(start + batch_size, total)
        batch = prompts[start:end]

        messages = [[{"role": "user", "content": prompt}] for prompt in batch]

        try:
            with torch.no_grad(): 
                results = pipe(messages, batch_size=len(batch))

            for index, result in enumerate(results):
                try:
                    df.at[start + index, "response"] = result[0]["generated_text"][1]["content"]
                except:
                    df.at[start + index, "response"] = "ERROR: Incorrect response format"

        except Exception as e:
            for i in range(start, end):
                df.at[i, "response"] = f"ERROR: {e}"

        df.to_csv(out_path, sep="\t", index=False)

        torch.cuda.empty_cache()  # ✅ frees unused cached VRAM
        print(f"Processed {end}/{total} prompts", flush=True)

    df.to_csv(out_path, sep="\t", index=False)
    print(f"\nDone. Saved output to: {out_path}")
