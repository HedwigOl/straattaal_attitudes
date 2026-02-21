// --- MAIN ---

let jsPsych = initJsPsych();

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

//Question about being disturbed in the experiment
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

// Demographics questionnaire trials
let demographics = {
  timeline : [demographics1, demographics2]
};

// Trial to save experiment data to the data server
let saveDataTrial = {
  type: jsPsychCallFunction,
  func: function() {
    uil.saveData(ACCESS_KEY, jsPsych.data.get().json());
  }
};

// End screen and redirection to Prolific
let end = {
  type: jsPsychHtmlButtonResponse,
  stimulus: style_UU + endExperiment,
  choices: ["Sluiten"],
  on_finish: function() {
    setTimeout(function () {
      window.location.href = "https://app.prolific.com/submissions/complete?cc=C1CUG1R5";
    }, 1200);
  },
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

    jsPsych.data.addProperties({subject_ID:  Math.floor(Math.random() * 10000) + 1,
                                group: group_name});
                                          
    let timeline = [consentProcedure, prolificID, environmentCheck, generalIatInstruction, 
                    IAT, explicitQuestionnaire, disturbedQuestion, demographics, saveDataTrial, end];

    jsPsych.run(timeline);
  });
};
