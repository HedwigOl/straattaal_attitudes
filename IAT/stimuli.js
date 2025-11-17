// --- STIMULI ---

// LABELS
// Target labels
const TAR_LABEL_A = 'STANDAARD NEDERLANDS';
const TAR_LABEL_B = 'STRAATTAAL';

// Attribute labels
const ATT_LABEL_A = 'MIGRANT';
const ATT_LABEL_B = 'NIET MIGRANT';

// STIMULI
// Target stimuli (words)
const WORDS_A = {
  'TAR_LABEL_A': ['geld', 'ruzie', 'huis', 'auto', 'liedje', 'schoen']};
const WORDS_B = { 
  'TAR_LABEL_B': ['doekoe', 'fittie', 'osso', 'waggie', 'pokoe', 'patta']};

// Attribute stimuli (names)
const NAMES_A = {
  'ATT_LABEL_A': ['Amira', 'Fatma', 'Samira', 'Salma', 'Mohamed', 'Ayoub', 'Murat', 'Ilias']};
const NAMES_B = {
  'ATT_LABEL_B': ['Anne', 'Esther', 'Julia', 'Laura', 'Martijn', 'Dennis', 'Jesse', 'Thomas']};

// COUNTERBALANCED KEY MAPPINGS
const COUNTERBALANCED_MAPPINGS = {
  group1: {
    'TAR_LABEL_A': 'left',
    'TAR_LABEL_B': 'right',
    'ATT_LABEL_A': 'right',
    'ATT_LABEL_B': 'left',
  },
  group2: {
    'TAR_LABEL_A': 'right',
    'TAR_LABEL_B': 'left',
    'ATT_LABEL_B': 'left',
    'ATT_LABEL_A': 'right'
  },
  group3: {
    'TAR_LABEL_A': 'left',
    'TAR_LABEL_B': 'right',
    'ATT_LABEL_B': 'right',
    'ATT_LABEL_A': 'left'
  },
  group4: {
    'TAR_LABEL_A': 'right',
    'TAR_LABEL_B': 'left',
    'ATT_LABEL_B': 'right',
    'ATT_LABEL_A': 'left'
  }
};

// CREATE STIMULI  
// Assign colors to the different categories
const categoryColors = {
  'TAR_LABEL_A': COLOR_TARGET,
  'TAR_LABEL_B': COLOR_TARGET,
  'ATT_LABEL_A': COLOR_ATTRIBUTE,
  'ATT_LABEL_B': COLOR_ATTRIBUTE
};

// Build stimuli and repeat each stimulus for desired amount
function buildStimuli(obj, repetitions, stimuli_type) {
  const stimuli = Object.entries(obj).flatMap(([category, words]) =>
    words.flatMap(word =>
      Array(repetitions).fill().map(() => ({
        stimulus: word,
        category,
        color: categoryColors[category],
        type_stim: stimuli_type
      }))
    )
  );
  return stimuli;
}

// randomization ensuring no stimuli are presented twice in a row and not four stimuli from the same category in a row
function shuffle(array) {
  const maxAttempts = 2000; 
  let attempts = 0;
  let shuffled;

  while (attempts < maxAttempts) {
    attempts++;

    shuffled = [...array];
    for (let i = shuffled.length - 1; i > 0; i--) {
      const j = Math.floor(Math.random() * (i + 1));
      [shuffled[i], shuffled[j]] = [shuffled[j], shuffled[i]];
    }

    let valid = true;
    for (let i = 1; i < shuffled.length; i++) {
      const curr = shuffled[i];
      const prev = shuffled[i - 1];

      // No identical stimulus twice in a row
      if (curr.stimulus === prev.stimulus) {
        valid = false;
        break;
      }

      // No four stimuli of the same categories in a row
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

// Create all stimuli
let targetStimuli_A    = buildStimuli(WORDS_A, REP_TARGET,    "target")
let targetStimuli_B    = buildStimuli(WORDS_B, REP_TARGET,    "target")
let attributeStimuli_A = buildStimuli(NAMES_A, REP_ATTRIBUTE, "attribute")
let attributeStimuli_B = buildStimuli(NAMES_B, REP_ATTRIBUTE, "attribute")

// Group into target and attribute stimuli
let targetStimuli       = shuffle([...targetStimuli_A,    ...targetStimuli_B]);
let attributeStimuli_b2 = shuffle([...attributeStimuli_A, ...attributeStimuli_B]); //random order for the two attribute blocks
let attributeStimuli_b5 = shuffle([...attributeStimuli_A, ...attributeStimuli_B]);