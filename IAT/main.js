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
        // activeer de knop alleen als alle vakjes zijn aangevinkt
        const allChecked = Array.from(checkboxes).every(cb => cb.checked);
        button.disabled = !allChecked;
      });
    });
  }
};

let general_iat_instruction = {
  type: jsPsychHtmlButtonResponse,
  stimulus: info_style_UU + iat_instructions,
  choices: ["Volgende"]
};

let combined_stimuli = alternateStimuli(stim_var_a, stim_var_b, stim_name_a, stim_name_b, keyConfigurationBlock3)

// Trial blocks of full IAT
let block1 = createIATBlock(keyConfigurationBlock1, ned_strttl_stimuli, true,  1)
let block2 = createIATBlock(keyConfigurationBlock2, ned_mig_stimuli,    true,  2)
let block3 = createIATBlock(keyConfigurationBlock3, combined_stimuli,   true,  3)
let block4 = createIATBlock(keyConfigurationBlock3, combined_stimuli,   false, 3)
let block5 = createIATBlock(keyConfigurationBlock4, ned_mig_stimuli,    true,  4)
let block6 = createIATBlock(keyConfigurationBlock5, combined_stimuli,   true,  5)
let block7 = createIATBlock(keyConfigurationBlock5, combined_stimuli,   false, 5)
let IAT = {timeline:[block1, block2, block3, block4, block5, block6, block7]}; 

//Question about being disturbed in the experiment
let disturbed = {
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

//End screen and redirection to Prolific
let end_screen = {
  type: jsPsychHtmlButtonResponse,
  stimulus: info_style_UU + end_experiment,
  choices: ["Sluiten"],
  on_finish: function() {window.location.href = "https://google.com";}
};

// Create timeline and run it
function main() {
  let timeline = [consent_procedure, prolific_ID, environment_check, general_iat_instruction, IAT, expl_questionnaire, disturbed, demographicsPage1, demographicsPage2, end_screen];
  jsPsych.run(timeline);
};