// --- MAIN ---

function main() {
let jsPsych = initJsPsych({
  on_finish: function() { jsPsych.data.displayData(); }
});

function assignStimulusKeys(stimuli, keyConfiguration) {
  return stimuli.map(s => ({
    stimulus: s.stimulus,
    stim_key_association: keyConfiguration[s.category]
  }));
}

// RANDOMIZATION
// Randomize key configuration language varieties
function randomkeyConfiguration(...categories) {
  return Math.random() < 0.5
    ? { [categories[0]]: 'left', [categories[1]]: 'right' }
    : { [categories[0]]: 'right', [categories[1]]: 'left' };
}

// Reverse a category mapping
function reversekeyConfiguration(keyConfiguration) {
  return Object.fromEntries(
    Object.entries(keyConfiguration).map(([k,v]) => [k, v === 'left' ? 'right' : 'left'])
  );
}

// Set key configurations for all blocks
let keyConfigurationBlock1 = randomkeyConfiguration('STANDAARD NEDERLANDS', 'STRAATTAAL');
let keyConfigurationBlock2 = randomkeyConfiguration('NIET MIGRANT', 'MIGRANT');
let keyConfigurationBlock3 = {...keyConfigurationBlock1, ...keyConfigurationBlock2};
let keyConfigurationBlock4 = reversekeyConfiguration(keyConfigurationBlock2);
let keyConfigurationBlock5 = {...keyConfigurationBlock1, ...keyConfigurationBlock4};


// Create fixation cross with labels present
function createFixationTrial (leftLabels, rightLabels, duration=250) {
  return {
    type: jsPsychIatHtml,
    stimulus: '<div class="stimulus">+</div>',
    force_correct_key_press: false,
    trial_duration: duration, 
    left_category_key: 'f',
    right_category_key: 'j',
    left_category_label: leftLabels,
    right_category_label: rightLabels,
    response_ends_trial: false}
  }
function createIATTrials(stimuli, leftLabels, rightLabels, fixationDuration=500) {
  return {
    timeline: [
      createFixationTrial(leftLabels, rightLabels, fixationDuration),
      {
        type: jsPsychIatHtml,
        stimulus: function() {
          return `<div class="stimulus">${jsPsych.timelineVariable('stimulus')}</div>`;
        },
        stim_key_association: function() { 
          return jsPsych.timelineVariable('stim_key_association');
        },
        html_when_wrong: '<span style="color:red;font-size:80px">X</span>',
        bottom_instructions: '<p>If you press the wrong key, a red X will appear. Press the other key to continue</p>',
        force_correct_key_press: true,
        display_feedback: true,
        trial_duration: 3000,
        left_category_key: 'f',
        right_category_key: 'j',
        left_category_label: leftLabels,
        right_category_label: rightLabels,
        response_ends_trial: true
      }
    ],
    timeline_variables: stimuli,
    randomize_order: true
  };
}


function instructionIAT (keyConfiguration){
  return {
    type: jsPsychHtmlKeyboardResponse,
    stimulus: function() {
      let leftCats = Object.keys(keyConfiguration).filter(k => keyConfiguration[k] == 'left');
      let rightCats = Object.keys(keyConfiguration).filter(k => keyConfiguration[k] == 'right');

      return `
      <div style="text-align:center; font-size:22px;">
        <p>In dit deel van het experiment ziet u steeds een naam of woord in het midden van het scherm.</p>
        <p>Uw taak is om dit woord zo snel en zo correct mogelijk in te delen in de juiste categorie.</p>
        <br>
        <p><b>Druk op (f)</span> voor  ${leftCats.join(" + ")}</b></p>
        <p><b>Druk op (j)</span> voor  ${rightCats.join(" + ")}</b></p>
        <br>
        <p style="margin-top:40px;">Druk op de <b>spatiebalk</b> om te beginnen.</p>
      </div>
    `;
  },
  choices: [' ']
  };
}

function createIATBlock(keyConfiguration, stimuli){
  return {
    timeline: [
    instructionIAT(keyConfiguration),
    createIATTrials(
      assignStimulusKeys(stimuli, keyConfiguration),
      Object.keys(keyConfiguration).filter(k => keyConfiguration[k] == 'left'),
      Object.keys(keyConfiguration).filter(k => keyConfiguration[k] == 'right')
    )
  ]
  }
}

//TRIAL BLOCKS
// 1: Straattaal vs. Standaard Nederlands
let block1 = createIATBlock(keyConfigurationBlock1, ned_strttl_stimuli)
let block2 = createIATBlock(keyConfigurationBlock2, ned_mig_stimuli)
let block3 = createIATBlock(keyConfigurationBlock3, ned_strttl_stimuli.concat(ned_mig_stimuli))
let block4 = createIATBlock(keyConfigurationBlock4, ned_mig_stimuli)
let block5 = createIATBlock(keyConfigurationBlock5, ned_strttl_stimuli.concat(ned_mig_stimuli))

let IAT = {timeline:[block1, block2, block3, block4, block5]};


//End screen and redirection to Prolific
let end_screen = {
  type: jsPsychHtmlButtonResponse,
  stimulus: end_experiment,
  choices: ["Sluiten"],
  on_finish: function() {window.location.href = "https://google.com";}
};

// Timeline of the full experiment
let timeline = [consent_procedure, prolific_ID, IAT, statements, demographics, end_screen];
jsPsych.run(timeline);
}