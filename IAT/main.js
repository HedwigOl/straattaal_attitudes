// --- MAIN ---

// Save data to data server at the end of the experiment
let jsPsych = initJsPsych({
  on_finish: function() {
    uil.saveData(ACCESS_KEY, jsPsych.data.get().json());}
});

// Information letter and consent procedure
let consentProcedure = {
    timeline: [informationLetter, consentPage, checkConsent]
};

// Record Prolific ID
let prolificID = {
  type: jsPsychSurveyText,
  preamble: style_UU + "",
  questions: [
    {
      prompt: "Wat is uw Prolific ID?",
      name: "Prolific_ID",
      required: true
    }
  ]
};

// Check for the test environment
var environmentCheck = {
  type: jsPsychHtmlButtonResponse,
  stimulus: style_UU + environmentText,
  choices: ['Verder'],
  data: {stimulus: "environment_check"}
};

// Discussion of the general IAT including the different stimuli and their categorisation
let generalIatInstruction = {
  type: jsPsychHtmlButtonResponse,
  stimulus: style_UU + iatInstructions,
  choices: ["Volgende"],
  data: {stimulus: "general_IAT_instruction"}
};

// Create full timeline of all IAT blocks
function createFullIAT (cb_keys){
  let block1 = createIATBlock(cb_keys.keyConfigurationBlock1, targetStimuli, 1)
  let block2 = createIATBlock(cb_keys.keyConfigurationBlock2, attributeStimuli_b2, 2)
  let block3 = createIATBlock(cb_keys.keyConfigurationBlock3, alternateStimuli(targetStimuli_A, 
    targetStimuli_B, attributeStimuli_A, attributeStimuli_B, cb_keys.keyConfigurationBlock3), 3)
  let block4 = createIATBlock(cb_keys.keyConfigurationBlock4, attributeStimuli_b5, 4)
  let block5 = createIATBlock(cb_keys.keyConfigurationBlock5, alternateStimuli(targetStimuli_A, 
    targetStimuli_B, attributeStimuli_A, attributeStimuli_B, cb_keys.keyConfigurationBlock5), 5)

  const blocks = [block1, block2, block3, block4, block5].map(b => b || []);
  return { timeline: blocks.flat() };
}

// Question about being disturbed in the experiment
let disturbedQuestion = {
  type: jsPsychSurveyText,
  preamble: style_UU + "",
  questions: [
    {
      prompt: "Werd u tijdens het experiment afgeleid?<br>(bijv. door iemand die binnenkwam of een telefoon die afging)",
      name: "disturbed",
      required: true,
      rows: 5,       
      columns: 60 
    }
  ]
};

// Demographics questionnaire
let demographics = {
  timeline : [demographics1, demographics2]
};

// End screen and redirection to Prolific (TODO: redirect to prolific site)
let end = {
  type: jsPsychHtmlButtonResponse,
  stimulus: style_UU + endExperiment,
  choices: ["Sluiten"],
  on_finish: function() {window.location.href = "https://google.com";},
  data: {stimulus: "end"}
};

// Create timeline and run it
function main() {
  uil.setAccessKey(ACCESS_KEY);
  uil.stopIfExperimentClosed();

  // Set key configuration based on counterbalanced group assignment
  uil.session.start(ACCESS_KEY, (group_name) => {

    const cb_keys = setupKeyConfiguration(group_name);
    let IAT = createFullIAT(cb_keys);

    // Add participant ID
    jsPsych.data.addProperties({subject_ID:  Math.floor(Math.random() * 10000) + 1,
                                group: group_name});
                                          
    let timeline = [consentProcedure, prolificID, environmentCheck, generalIatInstruction, 
                    IAT, explicitQuestionnaire, disturbedQuestion, demographics, end];

    jsPsych.run(timeline);
  });
};
