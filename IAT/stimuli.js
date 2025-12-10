// --- STIMULI ---

// Target stimuli (words)
const WORDS_A = {
  'STANDAARDNEDERLANDS': ['geld', 'ruzie', 'huis', 'auto', 'liedje', 'schoen']};
const WORDS_B = { 
  'STRAATTAAL'         : ['doekoe', 'fittie', 'osso', 'waggie', 'pokoe', 'patta']};

// Attribute stimuli (names)
const NAMES_A = {
  'MET MIGRATIEACHTERGROND'   : ['Amira', 'Fatma', 'Samira', 'Salma', 'Mohamed', 
                                  'Ayoub', 'Murat', 'Ilias']};
const NAMES_B = {
  'ZONDER MIGRATIEACHTERGROND': ['Anne', 'Esther', 'Julia', 'Laura', 'Martijn', 
                                 'Dennis', 'Jesse', 'Thomas']};

// COUNTERBALANCED KEY MAPPINGS
const COUNTERBALANCED_MAPPINGS = {
  group1: {
    'STANDAARDNEDERLANDS'       : 'left',
    'STRAATTAAL'                : 'right',
    'MET MIGRATIEACHTERGROND'   : 'right',
    'ZONDER MIGRATIEACHTERGROND': 'left',
  },
  group2: {
    'STANDAARDNEDERLANDS'       : 'right',
    'STRAATTAAL'                : 'left',
    'MET MIGRATIEACHTERGROND'   : 'right',
    'ZONDER MIGRATIEACHTERGROND': 'left'
  },
  group3: {
    'STANDAARDNEDERLANDS'       : 'left',
    'STRAATTAAL'                : 'right',
    'MET MIGRATIEACHTERGROND'   : 'left',
    'ZONDER MIGRATIEACHTERGROND': 'right'
  },
  group4: {
    'STANDAARDNEDERLANDS'       : 'right',
    'STRAATTAAL'                : 'left',
    'MET MIGRATIEACHTERGROND'   : 'left',
    'ZONDER MIGRATIEACHTERGROND': 'right'    
  }
};

// CREATE STIMULI  
// Assign colors to the different categories
const categoryColors = {
  'STANDAARDNEDERLANDS'       : COLOR_TARGET,
  'STRAATTAAL'                : COLOR_TARGET,
  'MET MIGRATIEACHTERGROND'   : COLOR_ATTRIBUTE,
  'ZONDER MIGRATIEACHTERGROND': COLOR_ATTRIBUTE
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

// Randomization with no stimuli presented twice in a row and not four stimuli from the same category in a row
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
let attributeStimuli_b2 = shuffle([...attributeStimuli_A, ...attributeStimuli_B]);
let attributeStimuli_b5 = shuffle([...attributeStimuli_A, ...attributeStimuli_B]);

let attributeStimuli_b5 = shuffle([...attributeStimuli_A, ...attributeStimuli_B]);
