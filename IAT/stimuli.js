// --- STIMULI ---

// Stimuli: Straattaal vs. Standard Dutch words
const languageVarieties = {
  'STANDAARD NEDERLANDS': ['Auto', 'Geld', 'Schoen', 'Weg'],
  'STRAATTAAL': ['Waggie', 'Doekoe', 'Patta', 'Loesoe']
};

// Stimuli: Names
const names = {
  'MIGRANT': ['Mohammed', 'Fatima', 'Ali', 'Zeynep'],
  'NIET MIGRANT': ['Jan', 'Petra', 'David', 'Lotte']
};

function buildStimuli(obj) {
  return Object.entries(obj).flatMap(([category, words]) =>
    words.map(word => ({ stimulus: word, category }))
  );
}

const ned_strttl_stimuli = buildStimuli(languageVarieties);
const ned_mig_stimuli = buildStimuli(names);


