// --- QUESTIONS ---

//record prolific ID
let prolific_ID = {
  type: jsPsychSurveyText,
  questions: [{prompt: 'Wat is uw Prolific ID?', name: 'Prolific_ID'}]
}

// Likert scale labels
let likert_scale = [
  "Helemaal mee oneens",
  "Oneens",
  "Beetje oneens",
  "Neutraal",
  "Beetje mee eens",
  "Mee eens",
  "Helemaal mee eens"
];

//Statements
let statements = {
  type: jsPsychSurveyLikert,
  questions: [
    {prompt: "Straattaal wordt vooral gesproken door mensen met een migratieachtergrond.", name: 'Vraag 1', labels: likert_scale},
    {prompt: "Jongens gebruiken vaker straattaal dan meisjes.", name: 'Vraag2', labels: likert_scale},
    {prompt: "Straattaal wordt vooral gesproken door mensen uit lagere sociale klassen.", name: 'Vraag3', labels: likert_scale},
    {prompt: "Mensen met geen migratieachtergrond gebruiken zelden Straattaal.", name: 'Vraag4', labels: likert_scale}
  ],
  randomize_question_order: true
};


//Demographics
// Demographics - styled similar to Qualtrics layout
let demographics = {
  type: jsPsychSurveyHtmlForm,
  preamble: `
    <style>
      body {
        background: rgb(246, 246, 246);
        font-family: "Open Sans", "Frutiger", Helvetica, Arial, sans-serif;
        color: rgb(33, 37, 41);
        text-align: left;
      }

      .demographics-container {
        max-width: 850px;
        margin: 40px auto;
        background: white;
        padding: 40px 50px;
        border-radius: 6px;
        box-shadow: 0 2px 6px rgba(0,0,0,0.1);
      }

      .demographics-container h2 {
        font-size: 1.8rem;
        border-bottom: 2px solid #ffcd00;
        padding-bottom: 10px;
        margin-bottom: 25px;
      }

      .form-row {
        display: flex;
        flex-wrap: wrap;
        justify-content: space-between;
        margin-bottom: 20px;
      }

      .form-group {
        flex: 1;
        min-width: 250px;
        margin-right: 20px;
      }

      .form-group:last-child {
        margin-right: 0;
      }

      label {
        display: block;
        font-weight: 600;
        margin-bottom: 6px;
      }

      input[type="text"],
      input[type="number"],
      select,
      textarea {
        width: 100%;
        border: 1px solid #ccc;
        border-radius: 4px;
        padding: 8px 10px;
        font-size: 15px;
        box-sizing: border-box;
        background: #fff;
      }

      textarea {
        resize: vertical;
      }

      .hidden {
        display: none;
      }

      .jspsych-survey-html-form-next {
        background: #000;
        color: #fff;
        border: none;
        font-weight: bold;
        font-size: 15px;
        padding: 12px 30px;
        cursor: pointer;
        border-radius: 4px;
        margin-top: 25px;
        display: block;
        margin-left: auto;
      }

      .jspsych-survey-html-form-next:hover {
        background: #222;
      }

      small {
        color: #666;
        display: block;
        margin-top: 15px;
      }
    </style>

    <div class="demographics-container">
      <h2>Vragen over uzelf</h2>
  `,
  html: `
    <div class="form-row">
      <div class="form-group">
        <label for="age">Leeftijd:</label>
        <input type="number" id="age" name="age" min="16" max="120" required>
      </div>
      <div class="form-group">
        <label for="gender">Geslacht:</label>
        <select id="gender" name="gender" required>
          <option value="">-- Selecteer --</option>
          <option value="Man">Man</option>
          <option value="Vrouw">Vrouw</option>
          <option value="Anders">Anders</option>
          <option value="Wil niet zeggen">Wil niet zeggen</option>
        </select>
      </div>
    </div>

    <div class="form-row">
      <div class="form-group">
        <label for="education">Opleidingsniveau:</label>
        <select id="education" name="education" required>
          <option value="">-- Selecteer --</option>
          <option value="Basisonderwijs">Basisonderwijs</option>
          <option value="Middelbaar onderwijs">Middelbaar onderwijs</option>
          <option value="MBO">MBO</option>
          <option value="HBO">HBO</option>
          <option value="WO">WO</option>
          <option value="Anders">Anders</option>
        </select>
      </div>
    </div>

    <div class="form-row">
      <div class="form-group">
        <label for="born_nl">Bent u in Nederland geboren?</label>
        <select id="born_nl" name="born_nl" required onchange="document.getElementById('born_nl_text').classList.toggle('hidden', this.value!='Nee');">
          <option value="">-- Selecteer --</option>
          <option value="Ja">Ja</option>
          <option value="Nee">Nee</option>
        </select>
      </div>
      <div class="form-group hidden" id="born_nl_text">
        <label for="born_nl_other">Waar bent u geboren?</label>
        <input type="text" id="born_nl_other" name="born_nl_other">
      </div>
    </div>

    <div class="form-row">
      <div class="form-group">
        <label for="parents_nl">Zijn uw ouders in Nederland geboren?</label>
        <select id="parents_nl" name="parents_nl" required onchange="document.getElementById('parents_nl_text').classList.toggle('hidden', this.value!='Nee');">
          <option value="">-- Selecteer --</option>
          <option value="Ja">Ja</option>
          <option value="Nee">Nee</option>
        </select>
      </div>
      <div class="form-group hidden" id="parents_nl_text">
        <label for="parents_nl_other">Waar zijn uw ouders geboren?</label>
        <input type="text" id="parents_nl_other" name="parents_nl_other">
      </div>
    </div>

    <div class="form-row">
      <div class="form-group" style="flex: 1;">
        <label for="languages">Gesproken moedertalen:</label>
        <textarea id="languages" name="languages" rows="3" placeholder="Bijv. Nederlands, Engels"></textarea>
      </div>
    </div>

    <small>Velden met * zijn verplicht.</small>
    </div>
  `,
  button_label: "Volgende"
};
