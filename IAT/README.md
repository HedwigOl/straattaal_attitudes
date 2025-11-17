# Straattaal IAT Experiment

This folder contains all the **JavaScript** and **HTML** files required to run the first experiment which includes an **Implicit Association Test**.

---

## Overview

The files make up for the entire experiment, which starts with the information letter and asking for consent. Thereafter, an Implicit association test starts which records response times and correctness for all trials. After the IAT, statements are presented to elicit explicit attitudes. The experiment ends with questions regarding the participant's demographics.

---

## Running the Experiment

The experiment is currently set up to be run in connection with the ILS data server. Therefore, counterbalancing and uploading the data is handled by this server.
To run the experiment locally, line `104` in `main.js` (about the server assignment into groups) should be substituded for a manual group assignment (e.g. `group1`). The full experiment can then be run by running the `index.html` file.

---

## Folder Contents

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

