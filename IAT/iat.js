// --- IAT---

// Assign the correct key to each stimulus
function assignStimulusKeys(stimuli, keyConfiguration) {
  return stimuli.map(s => ({
    ...s,
    stim_key_association: keyConfiguration[s.category]
  }));
}

// COUNTERBALANCING
function getKeyConfigurationForGroup(groupName) {
  return COUNTERBALANCED_MAPPINGS[groupName];
}

// RANDOMIZATION
// Randomize key configuration language varieties (TO DO delete when counterbalancing is fully working and checked)
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

// Returns the key mappings based on the counterbalanced conditions
function setup_key_configuration(groupName) {
  const keyConfig = getKeyConfigurationForGroup(groupName);

  const keyConfigurationBlock1 = {
    label_target_A: keyConfig[label_target_A],
    label_target_B: keyConfig[label_target_B]};
  const keyConfigurationBlock2 = {
    label_attribute_B: keyConfig[label_attribute_B],
    label_attribute_A: keyConfig[label_attribute_A]};
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

// Set key configurations for all blocks (randomised version) (if using replace with label_??)
//let keyConfigurationBlock1 = randomkeyConfiguration('STANDAARD NEDERLANDS', 'STRAATTAAL');
//let keyConfigurationBlock2 = randomkeyConfiguration('NIET MIGRANT', 'MIGRANT');
//let keyConfigurationBlock3 = {...keyConfigurationBlock1, ...keyConfigurationBlock2};
//let keyConfigurationBlock4 = reversekeyConfiguration(keyConfigurationBlock2);
//let keyConfigurationBlock5 = {...keyConfigurationBlock1, ...keyConfigurationBlock4};

//alternate stimuli using procedure of Greenwald et al., 2022
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

// Create fixation cross with labels present
function createFixationTrial (leftLabels, rightLabels, duration=250) {
  return {
    type: jsPsychIatHtml,
    stimulus: '<div class="stimulus">+</div>',
    stim_key_association: ' ',
    force_correct_key_press: false,
    trial_duration: duration, 
    left_category_key: LEFT_KEY,
    right_category_key: RIGHT_KEY,
    left_category_label: colorLabels(leftLabels),
    right_category_label: colorLabels(rightLabels),
    response_ends_trial: false}
  }

function colorLabels(labelsArray) {
  return labelsArray.map(label => {
    const color = categoryColors[label] || 'black';
    return `<span style="color:${color}; font-weight:bold;">${label}</span>`;
  });
}

// Create all trials for the IAT
function createIATTrials(stimuli, leftLabels, rightLabels, fixationDuration = 500) {

  return {
    timeline: [
      createFixationTrial(leftLabels, rightLabels, fixationDuration),
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
        response_ends_trial: true
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

      return `
        <div style="position: relative; font-size: 18px; width: 900px; margin: auto; padding: 20px;">

          <div style="display: flex; justify-content: center; gap: 400px; font-size: 18px; line-height: 1; margin-top: 80px;">
            <div style="text-align:center;">
              <p>Druk 'f' voor:</p>
              ${colorLabels(leftCats).join(" <br>+<br> ")}
            </div>
            <div style="text-align:center;">
              <p>Druk 'j' voor:</p>
              ${colorLabels(rightCats).join(" <br>+<br> ")}
            </div>
          </div>

          <br><br>

          <div style="text-align: center; font-size: 18px;">
            <u>Deel ${block_nr} van 5</u>
          </div>

          <br>

          <div style="font-size: 18px; line-height: 1;">
            <p>Druk met uw linkervinger op de <b>f</b>-toets voor items die behoren tot de categorie ${colorLabels(leftCats).join(" + ")}.</p>
            <p>Druk met uw rechtervinger op de <b>j</b>-toets voor items die behoren tot de categorie ${colorLabels(rightCats).join(" + ")}. De items verschijnen één voor één.</p>
            <p>Als u een fout maakt, verschijnt er een rood <span style="color:red; font-weight:bold;">X</span>. Druk dan op de andere toets om verder te gaan.</p>
            <p><u>Probeer steeds zo snel mogelijk te antwoorden</u> terwijl u nauwkeurig blijft.</p>
          </div>

          <br><br>

          <div style="text-align: center; font-size: 20px;">
            Druk op de <b>spatiebalk</b> wanneer u klaar bent om te beginnen.
          </div>

        </div>
      `;
    },
    choices: [' '],
    response_ends_trial: true
  };
}

// Create a full IAT block including instruction if desired
function createIATBlock(keyConfiguration, stimuli, instructions, block_number) {

  const timeline = [];

  if (instructions) {
    timeline.push(instructionIAT(keyConfiguration, block_number));
  }

  timeline.push(
    createIATTrials(
      assignStimulusKeys(stimuli, keyConfiguration),
      Object.keys(keyConfiguration).filter(k => keyConfiguration[k] === 'left'),
      Object.keys(keyConfiguration).filter(k => keyConfiguration[k] === 'right')
    )
  );

  return { timeline };
}
