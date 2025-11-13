// --- MAIN ---
// File creates and stars jspsych timeline

let jsPsych = initJsPsych({
  on_finish: function() { jsPsych.data.displayData(); }
});

// Information letter and consent procedure
let consent_procedure = {
    timeline: [info_pages, consent_page, if_node_consent]
};

// Record Prolific ID
let prolific_ID = {
  type: jsPsychSurveyText,
  preamble: info_style_UU + "",
  questions: [
    {
      prompt: "Wat is uw Prolific ID?",
      name: "Prolific_ID",
      required: true
    }
  ]
};

// Check for the test environment
var environment_check = {
  type: jsPsychHtmlButtonResponse,
  stimulus: info_style_UU + environment_text,
  choices: ['Verder'],
  button_html: '<button class="jspsych-btn" disabled>%choice%</button>', // only allow continueing when all boxess are checked
  on_load: function() {
    const checkboxes = document.querySelectorAll('.check-item');
    const button = document.querySelector('.jspsych-btn');

    checkboxes.forEach(box => {
      box.addEventListener('change', () => {
        const allChecked = Array.from(checkboxes).every(cb => cb.checked);
        button.disabled = !allChecked;
      });
    });
  }
};

// Discussion of the general IAT including the different stimuli and their categorisation
let general_iat_instruction = {
  type: jsPsychHtmlButtonResponse,
  stimulus: info_style_UU + iat_instructions,
  choices: ["Volgende"]
};

// Create full timeline of all IAT blocks
function createFullIAT (cb_keys){
  let block1 = createIATBlock(cb_keys.keyConfigurationBlock1, target_stimuli, true, 1)
  let block2 = createIATBlock(cb_keys.keyConfigurationBlock2, attribute_stimuli_2, true, 2)
  let block3 = createIATBlock(cb_keys.keyConfigurationBlock3, alternateStimuli(stim_var_a, stim_var_b, stim_name_a, stim_name_b, cb_keys.keyConfigurationBlock3), true, 3)
  let block4 = createIATBlock(cb_keys.keyConfigurationBlock3, alternateStimuli(stim_var_a, stim_var_b, stim_name_a, stim_name_b, cb_keys.keyConfigurationBlock3), false, 3)
  let block5 = createIATBlock(cb_keys.keyConfigurationBlock4, attribute_stimuli_5, true, 4)
  let block6 = createIATBlock(cb_keys.keyConfigurationBlock5, alternateStimuli(stim_var_a, stim_var_b, stim_name_a, stim_name_b, cb_keys.keyConfigurationBlock5), true, 5)
  let block7 = createIATBlock(cb_keys.keyConfigurationBlock5, alternateStimuli(stim_var_a, stim_var_b, stim_name_a, stim_name_b, cb_keys.keyConfigurationBlock5), false, 5)

  const blocks = [block1, block2, block3, block4, block5, block6, block7].map(b => b || []);
  return { timeline: blocks.flat() };
}

//Question about being disturbed in the experiment
let disturbed_question = {
  type: jsPsychSurveyText,
  preamble: info_style_UU + "",
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

let demographics = {
  timeline : [demographics_1, demographics_2]
};

//End screen and redirection to Prolific (TODO: redirect to prolific site)
let end_screen = {
  type: jsPsychHtmlButtonResponse,
  stimulus: info_style_UU + end_experiment,
  choices: ["Sluiten"],
  on_finish: function() {
        uil.saveJson(jsPsych.data.get().json(), ACCESS_KEY);}
  //on_finish: function() {window.location.href = "https://google.com";}
};

// Create timeline and run it
function main() {
  uil.setAccessKey(ACCESS_KEY);
  uil.stopIfExperimentClosed();

  // way to test (TODO: remove when experiment is hosted)
  const group_name = "group1";

  // Set key configuration based on counterbalanced group assignment
  //uil.session.start(ACCESS_KEY, (group_name) => {

    const cb_keys = setup_key_configuration(group_name);
    let IAT = createFullIAT(cb_keys);

    let timeline = [consent_procedure, prolific_ID, environment_check, general_iat_instruction, 
                    IAT, expl_questionnaire, disturbed_question, demographics, end_screen];
    
    jsPsych.run(timeline);
  //});
};