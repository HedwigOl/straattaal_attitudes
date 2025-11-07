// --- STIMULI ---

// Labels for the target and attribute categories
const label_target_A = 'STANDAARD NEDERLANDS';
const label_target_B = 'STRAATTAAL';
const label_attribute_A = 'MIGRANT';
const label_attribute_B = 'NIET MIGRANT';


// Target stimuli
const variety_a = {
  label_target_A: ['geld', 'ruzie', 'huis', 'auto', 'liedje', 'schoen']};

const variety_b = { 
  label_target_B: ['doekoe', 'fittie', 'osso', 'waggie', 'pokoe', 'patta']};

// Attribute stimuli
const names_a = {
  label_attribute_A: ['Amira', 'Fatma', 'Samira', 'Salma', 'Mohamed', 'Ayoub', 'Murat', 'Ilias']};

const names_b = {
  label_attribute_B: ['Anne', 'Esther', 'Julia', 'Laura', 'Martijn', 'Dennis', 'Jesse', 'Thomas']};

// Assign colours to the different categories
const categoryColors = {
  label_target_A: COLOR_TARGET,
  label_target_B: COLOR_TARGET,
  label_attribute_A: COLOR_ATTRIBUTE,
  label_attribute_B: COLOR_ATTRIBUTE
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

// randomization ensuring no stimuli are presented twice in a row and not four stimuli from the same category in a row
function shuffle(array) {
  const maxAttempts = 1000; 
  let attempts = 0;
  let shuffled;

  while (attempts < maxAttempts) {
    attempts++;

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

      // No identical stimulus twice in a row
      if (curr.stimulus === prev.stimulus) {
        valid = false;
        break;
      }

      // No 4 stimuli of the same categories in a row
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
let stim_var_a = buildStimuli(variety_a, REP_VAR)
let stim_var_b = buildStimuli(variety_b, REP_VAR)
let stim_name_a = buildStimuli(names_a, REP_NAME)
let stim_name_b = buildStimuli(names_b, REP_NAME)

// Group into target and attribute stimuli
let target_stimuli = shuffle([...stim_var_a, ...stim_var_b]);
let attribute_stimuli = shuffle([...stim_name_a, ...stim_name_b]);

// Set fixed key mappings for the four counterbalanced groups
const COUNTERBALANCED_MAPPINGS = {
  group1: {
    label_target_A: 'left',
    label_target_B: 'right',
    label_attribute_B: 'left',
    label_attribute_A: 'right'
  },
  group2: {
    label_target_A: 'right',
    label_target_B: 'left',
    label_attribute_B: 'left',
    label_attribute_A: 'right'
  },
  group3: {
    label_target_A: 'left',
    label_target_B: 'right',
    label_attribute_B: 'right',
    label_attribute_A: 'left'
  },
  group4: {
    label_target_A: 'right',
    label_target_B: 'left',
    label_attribute_B: 'right',
    label_attribute_A: 'left'
  }
};