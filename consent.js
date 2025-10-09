// --- CONSENT ---

let consent_given = null;

const info_style_UU = `<style>
        body {
            background: rgb(246, 246, 246);
            font-family: "Open Sans","Frutiger",Helvetica,Arial,sans-serif;
            color: rgb(33, 37, 41);
            text-align: left;
        }
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
            margin: 5px;
        }
        button:hover, .jspsych-btn:hover {
            opacity: 0.8;
        }
    </style>`;

 // Information pages
const info_pages = {
  type: jsPsychInstructions,
  pages: [information_letter_1 + info_style_UU, information_letter_2 + info_style_UU],
  show_clickable_nav: true,
  button_label_next: "Volgende",
  button_label_previous: "Vorige"
};   

// Consent page
let consent_page = {
    type: jsPsychHtmlButtonResponse,
    stimulus: info_style_UU + consent_text,
    choices: ["Ik ga akkoord", "Ik ga niet akkoord"],
    on_finish: function(data){
        if(data.response === 0){    // Consent given
            consent_given = true;}

        else {                      // No consent
            consent_given = false;}
    }
};

// End when no consent given
let no_consent_end_screen = {
    type: jsPsychHtmlButtonResponse,
    stimulus: no_consent + info_style_UU,
    choices: [],
    on_finish: function(){
        jsPsych.endExperiment();
    }
};

// Consent logic
let if_node_consent = {
    timeline: [no_consent_end_screen],
    conditional_function: function(){
        return !consent_given;
    }
};

let consent_procedure = {
    timeline: [info_pages, consent_page, if_node_consent]
};

