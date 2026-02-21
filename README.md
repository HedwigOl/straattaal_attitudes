# 

This is the repository of the master's thesis "Implicit and Explicit Language Attitudes toward the Dutch Multiethnolect Straattaal in Humans and Large Language Models".

---

## Overview

In this repository are the **Javascript** files for the Implicit Association Test conducted with human participants and the **Python** files with the code for creating prompts, running prompt,
and extracting the responses in the desired format from the LLM output. For all experiments, **R** files aren included used in data analysis.

---

## Contents

- `index.html`        – HTML file to run the experiment.
- `main.js`           - File to create the overall timeline of the experiment.
- `stimuli.js`        - Creation of stimuli and labels.
- `questions.js`      - Questions used in the explicit questionnaire and demographics section.
- `globals.js`        - Global variables and the acces key for connecting the experiment to the data server.
- `iat.js`            - Creates the IAT trials, fixations between trials and block specific instructions.
- `consent.js`           - Consent procedure including ending the experiment if no consent is given.
- `instructions.js`      - Instruction letter and instructions for the different parts of the experiment.
- `jspsych_iat_dutch.js` - JsPsych's IAT plugin updated with Dutch instructions.

---
