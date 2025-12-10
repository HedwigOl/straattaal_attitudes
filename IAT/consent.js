// --- CONSENT ---

let consent = null;

// General UU style for information pages and questionnaire
const style_UU = `<style>
        body {
            background: rgb(246, 246, 246);
            font-family: "Open Sans","Frutiger",Helvetica,Arial,sans-serif;
            color: rgb(33, 37, 41);
            text-align: left; }
        p { line-height: 1.4; }
        h1, h2 { font-size: 2rem; }
        button, .jspsych-btn {
            background: #000;
            color: #fff;
            border: none;
            font-weight: bold;
            font-size: 15px;
            padding: 0 20px;
            line-height: 42px;
            cursor: pointer;
            margin: 5px;}
        button:hover, .jspsych-btn:hover {
            opacity: 0.8;}
    </style>`;

 // Information letter
let informationLetter = {
  type: jsPsychInstructions,
  pages: [informationLetter1 + style_UU, informationLetter2 + style_UU],
  show_clickable_nav: true,
  button_label_next: "Volgende",
  button_label_previous: "Vorige"
};   

// Consent page
let consentPage = {
    type: jsPsychHtmlButtonResponse,
    stimulus: consentText + style_UU,
    choices: ["Ik ga niet akkoord", "Ik ga akkoord"],
    data: {stimulus: "consent"},
    on_finish: function(data){
        if(data.response === 1){  // Consent given
            consent = true;}
        else {                    // No consent given
            consent = false;}
    }
};

// End when no consent is given
let noConsentEnd = {
    type: jsPsychHtmlButtonResponse,
    stimulus: noConsent + style_UU,
    choices: [],
    on_finish: function(){
        jsPsych.endExperiment();
    }
};

// Consent logic
let checkConsent = {
    timeline: [noConsentEnd],
    conditional_function: function(){
        return !consent;
    }
};
};
