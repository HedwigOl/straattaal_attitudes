// --- IAT---

// Assign the correct key to each stimulus
function assignStimulusKeys(stimuli, keyConfiguration) {
  return stimuli.map(s => ({
    ...s,
    stim_key_association: keyConfiguration[s.category]
  }));
}

// Reverse a category mapping
function reversekeyConfiguration(keyConfiguration) {
  return Object.fromEntries(
    Object.entries(keyConfiguration).map(([k,v]) => [k, v === 'left' ? 'right' : 'left'])
  );
}

// Returns the key mappings based on the counterbalanced conditions
function setupKeyConfiguration(groupName) {
  const keyConfig = COUNTERBALANCED_MAPPINGS[groupName];

  const keyConfigurationBlock1 = {
    'TAR_LABEL_A': keyConfig['TAR_LABEL_A'],
    'TAR_LABEL_B': keyConfig['TAR_LABEL_B']};
  const keyConfigurationBlock2 = {
    'ATT_LABEL_A': keyConfig['ATT_LABEL_A'],
    'ATT_LABEL_B': keyConfig['ATT_LABEL_B']};
  const keyConfigurationBlock3 = { ...keyConfigurationBlock1, ...keyConfigurationBlock2 };
  const keyConfigurationBlock4 = reversekeyConfiguration(keyConfigurationBlock2);
  const keyConfigurationBlock5 = { ...keyConfigurationBlock1, ...keyConfigurationBlock4 };

  return {
    keyConfigurationBlock1,
    keyConfigurationBlock2,
    keyConfigurationBlock3,
    keyConfigurationBlock4,
    keyConfigurationBlock5
  };
}

// Alternate stimuli using procedure of Greenwald et al., 2022
function alternateStimuli(targets_A, targets_B, attributes_A, attributes_B) {

  let tA = jsPsych.randomization.shuffle([...targets_A]);
  let tB = jsPsych.randomization.shuffle([...targets_B]);
  let aA = jsPsych.randomization.shuffle([...attributes_A]);
  let aB = jsPsych.randomization.shuffle([...attributes_B]);

  const combined = [];

  const numBlocks = Math.floor(Math.max(tA.length + tB.length, aA.length + aB.length) / 2);

  for (let block = 0; block < numBlocks; block++) {
    // Pick target stimuli for odd trials, and attribute stimuli for even ones
    let oddTarget1 = tA.length ? tA.pop() : tB.pop();
    let oddTarget3 = tB.length ? tB.pop() : tA.pop();
    let evenAttr2 = aA.length ? aA.pop() : aB.pop();
    let evenAttr4 = aB.length ? aB.pop() : aA.pop();

    const blockTrials = [oddTarget1, evenAttr2, oddTarget3, evenAttr4];

    const oddIndices = [0, 2];
    const shuffledOdd = jsPsych.randomization.shuffle(oddIndices.map(i => blockTrials[i]));
    oddIndices.forEach((idx, j) => { blockTrials[idx] = shuffledOdd[j]; });
    const evenIndices = [1, 3];
    const shuffledEven = jsPsych.randomization.shuffle(evenIndices.map(i => blockTrials[i]));
    evenIndices.forEach((idx, j) => { blockTrials[idx] = shuffledEven[j]; });

    combined.push(...blockTrials);
  }
  return combined;
}

// Create fixation trial with labels present
function createFixationTrial (leftLabels, rightLabels) {
  return {
    type: jsPsychIatHtml,
    stimulus: '<div class="stimulus"></div>',
    stim_key_association: ' ',
    force_correct_key_press: false,
    trial_duration: TRIAL_INTERVAL, 
    left_category_key: LEFT_KEY,
    right_category_key: RIGHT_KEY,
    left_category_label: colorLabels(leftLabels),
    right_category_label: colorLabels(rightLabels),
    response_ends_trial: false,
    data: {stimulus: 'fixation'}
  }
}

// Add colors to the labels of the attribute categories
function colorLabels(labelsArray) {
  return labelsArray.map(label => {
    const color = categoryColors[label] || 'black';
    return `<span style="color:${color}; font-weight:bold;">${label}</span>`;
  });
}

// Create all trials for the IAT
function createIATTrials(stimuli, leftLabels, rightLabels, nr_block) {

  return {
    timeline: [
      createFixationTrial(leftLabels, rightLabels),
      {
        type: jsPsychIatHtml,
        stimulus: function() {
          const stim = jsPsych.timelineVariable('stimulus');
          const color = jsPsych.timelineVariable('color');
          return `<div class="stimulus" style="color:${color}; font-size:60px;">${stim}</div>`;
        },
        stim_key_association: function() {
          return jsPsych.timelineVariable('stim_key_association');
        },
        html_when_wrong: '<span style="color:red;font-size:80px">X</span>',
        force_correct_key_press: true,
        display_feedback: true,
        trial_duration: 3000,
        left_category_key: LEFT_KEY,
        right_category_key: RIGHT_KEY,
        left_category_label: colorLabels(leftLabels),
        right_category_label: colorLabels(rightLabels),
        response_ends_trial: true,
        data: {
          stimulus: jsPsych.timelineVariable('stimulus'),
          categorie: jsPsych.timelineVariable('category'),
          left_key: leftLabels,
          right_key: rightLabels,
          attr_tar: jsPsych.timelineVariable('type_stim'),
          trial_block: nr_block
        }
      }
    ],
    timeline_variables: stimuli,
    randomize_order: false
  };
}

// Create instruction screen for every IAT block
function instructionIAT(keyConfiguration, block_nr) {
  return {
    type: jsPsychHtmlKeyboardResponse,
    stimulus: function() {
      let leftCats = Object.keys(keyConfiguration).filter(k => keyConfiguration[k] == 'left');
      let rightCats = Object.keys(keyConfiguration).filter(k => keyConfiguration[k] == 'right');
      return blockInstruction(leftCats, rightCats, block_nr)
    },
    choices: [' '],
    response_ends_trial: true,
    data: {stimulus: 'iat_instructon'}
  };
}

// Create a full IAT block including instruction if desired
function createIATBlock(keyConfiguration, stimuli, instructions, partNumber, blockNumber) {

  const timeline = [];

  if (instructions) {
    timeline.push(instructionIAT(keyConfiguration, partNumber));
  }

  timeline.push(
    createIATTrials(
      assignStimulusKeys(stimuli, keyConfiguration),
      Object.keys(keyConfiguration).filter(k => keyConfiguration[k] === 'left'),
      Object.keys(keyConfiguration).filter(k => keyConfiguration[k] === 'right'),
      blockNumber
    )
  );

  return {timeline};
}


// RANDOMIZATION
// Randomize key configuration language varieties (TO DO delete when counterbalancing is fully working and checked)
function randomkeyConfiguration(...categories) {
  return Math.random() < 0.5
    ? { [categories[0]]: 'left', [categories[1]]: 'right' }
    : { [categories[0]]: 'right', [categories[1]]: 'left' };
}

// Set key configurations for all blocks (randomised version) (if using replace with label_??)
//let keyConfigurationBlock1 = randomkeyConfiguration('TAR_LABEL_A', 'STRAATTAAL');
//let keyConfigurationBlock2 = randomkeyConfiguration('NIET MIGRANT', 'MIGRANT');
//let keyConfigurationBlock3 = {...keyConfigurationBlock1, ...keyConfigurationBlock2};
//let keyConfigurationBlock4 = reversekeyConfiguration(keyConfigurationBlock2);
//let keyConfigurationBlock5 = {...keyConfigurationBlock1, ...keyConfigurationBlock4};
