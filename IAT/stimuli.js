// --- STIMULI ---

// Stimuli: Straattaal vs. Standard Dutch words
const variety_a = {
  'STANDAARD NEDERLANDS': ['geld', 'ruzie', 'huis', 'auto', 'liedje', 'schoen']};

const variety_b = { 
  'STRAATTAAL': ['doekoe', 'fittie', 'osso', 'waggie', 'pokoe', 'patta']};

// Stimuli: Names
const names_a = {
  'MIGRANT': ['Amira', 'Fatma', 'Samira', 'Salma', 'Mohamed', 'Ayoub', 'Murat', 'Ilias']};

const names_b = {
  'NIET MIGRANT': ['Anne', 'Esther', 'Julia', 'Laura', 'Martijn', 'Dennis', 'Jesse', 'Thomas']};

// Assign colours to the different categories
const categoryColors = {
  'STANDAARD NEDERLANDS': COLOR_TARGET,
  'STRAATTAAL': COLOR_TARGET,
  'MIGRANT': COLOR_ATTRIBUTE,
  'NIET MIGRANT': COLOR_ATTRIBUTE
};

// Build stimuli and repeat for desired amount
function buildStimuli(obj, repetitions) {
  const stimuli = Object.entries(obj).flatMap(([category, words]) =>
    words.flatMap(word =>
      Array(repetitions).fill().map(() => ({
        stimulus: word,
        category,
        color: categoryColors[category]
      }))
    )
  );
  return stimuli;
}

// randomization function ensuring no stimuli are presented twice in a row and not four stimuli from
// the same category
function shuffle(array) {
  const maxAttempts = 1000; 
  let attempts = 0;
  let shuffled;

  while (attempts < maxAttempts) {
    attempts++;

    // Simple Fisher-Yates shuffle
    shuffled = [...array];
    for (let i = shuffled.length - 1; i > 0; i--) {
      const j = Math.floor(Math.random() * (i + 1));
      [shuffled[i], shuffled[j]] = [shuffled[j], shuffled[i]];
    }

    // Check constraints
    let valid = true;
    for (let i = 1; i < shuffled.length; i++) {
      const curr = shuffled[i];
      const prev = shuffled[i - 1];

      // 1. No identical stimulus twice in a row
      if (curr.stimulus === prev.stimulus) {
        valid = false;
        break;
      }

      // 2. No more than 3 same categories consecutively
      if (
        i >= 3 &&
        shuffled[i - 1].category === curr.category &&
        shuffled[i - 2].category === curr.category &&
        shuffled[i - 3].category === curr.category
      ) {
        valid = false;
        break;
      }
    }

    if (valid) return shuffled;
  }
}

let stim_var_a = buildStimuli(variety_a, REP_VAR)
let stim_var_b = buildStimuli(variety_b, REP_VAR)
let stim_name_a = buildStimuli(names_a, REP_NAME)
let stim_name_b = buildStimuli(names_b, REP_NAME)

let ned_strttl_stimuli = shuffle([...stim_var_a, ...stim_var_b]);
let ned_mig_stimuli = shuffle([...stim_name_a, ...stim_name_b]);
