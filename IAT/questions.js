// --- QUESTIONS ---

// Likert scale labels
let likert_ethnicity = ["migrant", "", "", "", "", "", "niet migrant"];
let likert_gender    = ["man", "", "", "", "", "", "vrouw"];
let likert_age       = ["jong", "", "", "", "", "", "oud"];
let likert_location  = ["randstad", "", "", "", "", "", "niet randstad"];
let likert_class     = ["hoge sociale klasse", "", "", "", "", "", "lage sociale klasse"];
let likert_rating    = ["positief", "", "", "", "", "", "negatief"]

// Randomize likert scales
function randomizelabel(labels) {
  if (Math.random() < 0.5) {
    return labels.slice().reverse();
  }
  return labels.slice();
}

const straattaal_woorden = "doekoe, waggie, osso, fittie, patta, pokoe"
const nederlands_woorden = "auto, ruzie, liedje, schoen, geld, huis"

// Create explicit questionnaire
function createSurveyBlock(languageLabel, example_words) {
  return {
    type: jsPsychSurveyLikert,
    preamble: ` 
      ${info_style_UU}
      <div style="max-width: 800px; margin: 0 auto; font-size:18px;">
        <p><b>In hoeverre associeert u de volgende kenmerken met ${languageLabel} (woorden zoals: ${example_words}) en sprekers hiervan?</b></p>
        <p><i>Selecteer een bolletje: hoe dichter u bij een van de kenmerken kiest, sterker u dat kenmerk associeert met <b>${languageLabel}</b>.</i></p>
      </div>`,
    questions: [
      {prompt: `Welke achtergrond associeert u met sprekers van <b>${languageLabel}</b>?`, name: `Ethnicity_${languageLabel}`, labels: randomizelabel(likert_ethnicity)},
      {prompt: `Welke geslacht associeert u met sprekers van <b>${languageLabel}</b>?`, name: `Gender_${languageLabel}`, labels: randomizelabel(likert_gender)},
      {prompt: `Welke leeftijd associeert u met sprekers van <b>${languageLabel}</b>?`, name: `Age_${languageLabel}`, labels: randomizelabel(likert_age)},
      {prompt: `Welke woonplek associeert u met sprekers van <b>${languageLabel}</b>?`, name: `Location_${languageLabel}`, labels: randomizelabel(likert_location)},
      {prompt: `Welke sociale klasse associeert u met sprekers van <b>${languageLabel}</b>?`, name: `Class_${languageLabel}`, labels: randomizelabel(likert_class)},
      {prompt: `Hoe staat u tegenover het gebruik van <b>${languageLabel}</b>?`, name: `Rating_${languageLabel}`, labels: randomizelabel(likert_rating)}
    ],
    randomize_question_order: true
  };
}

// Create timeline for explicit questionnaire with randomized order of pages
let expl_questionnaire = {
  timeline: [createSurveyBlock("STRAATTAAL", straattaal_woorden), createSurveyBlock("STANDAARD NEDERLANDS", nederlands_woorden)]
    .sort(() => Math.random() - 0.5)
};

// Demographics page 1
let demographics_1 = {
  type: jsPsychSurveyHtmlForm,
  preamble: `
    ${info_style_UU}
    <div style="max-width: 800px; margin: 5px auto; font-size: 18px;">
      <h3 style="margin-bottom: 10px;">Vul onderstaande vragen over uzelf in:</h3>
    </div>
  `,
  html: `
    ${info_style_UU}
    <div style="margin-bottom: 30px;">
      <label for="age"><strong>Leeftijd:</strong></label>
      <input type="number" id="age" name="age" min="16" max="120" required style="width: 100%; padding: 8px;">
    </div>

    <div style="margin-bottom: 30px;">
      <label for="gender"><strong>Geslacht:</strong></label>
      <select id="gender" name="gender" required style="width: 100%; padding: 8px;">
        <option value="">-- Selecteer --</option>
        <option value="Man">Man</option>
        <option value="Vrouw">Vrouw</option>
        <option value="Non-binair">Non-binair</option>
        <option value="Anders">Anders</option>
        <option value="Wil niet zeggen">Wil niet zeggen</option>
      </select>
    </div>

    <div style="margin-bottom: 30px;">
      <label for="education"><strong>Opleidingsniveau:</strong></label>
      <select id="education" name="education" required style="width: 100%; padding: 8px;">
        <option value="">-- Selecteer --</option>
        <option value="Basisonderwijs">Basisonderwijs</option>
        <option value="Middelbaar onderwijs">Middelbaar onderwijs</option>
        <option value="MBO">MBO</option>
        <option value="HBO">HBO</option>
        <option value="WO">WO</option>
        <option value="Anders">Anders</option>
      </select>
    </div>

    <div style="margin-bottom: 30px;">
      <label for="randstad"><strong>Woont u in de Randstad?</strong></label>
      <select id="randstad" name="randstad" required onchange="document.getElementById('randstad_text').style.display = this.value === 'Ik twijfel' ? 'block' : 'none';" style="width: 100%; padding: 8px;">
        <option value="">-- Selecteer --</option>
        <option value="Ja">Ja</option>
        <option value="Nee">Nee</option>
        <option value="Ik twijfel">Ik twijfel</option>
      </select>
    </div>

    <div id="randstad_text" style="display: none; margin-bottom: 30px;">
      <label for="randstad_other"><strong>Waar woont u?</strong></label>
      <input type="text" id="randstad_other" name="randstad_other" style="width: 100%; padding: 8px;">
    </div>
  `,
  button_label: "Volgende"
};

// Demograpics page 2
let demographics_2 = {
  type: jsPsychSurveyHtmlForm,
  preamble: `
    ${info_style_UU}
    <div style="max-width: 800px; margin: 5px auto; font-size: 18px;">
      <h3 style="margin-bottom: 10px;">Vul onderstaande vragen over uzelf in:</h3>
    </div>
  `,
  html: `
    ${info_style_UU}
    <div style="margin-bottom: 30px;">
      <label for="born_nl"><strong>Bent u in Nederland geboren?</strong></label>
      <select id="born_nl" name="born_nl" required onchange="document.getElementById('born_nl_text').style.display = this.value === 'Nee' ? 'block' : 'none';" style="width: 100%; padding: 8px;">
        <option value="">-- Selecteer --</option>
        <option value="Ja">Ja</option>
        <option value="Nee">Nee</option>
      </select>
    </div>
    <div id="born_nl_text" style="display: none; margin-bottom: 30px;">
      <label for="born_nl_other"><strong>Waar bent u geboren?</strong></label>
      <input type="text" id="born_nl_other" name="born_nl_other" style="width: 100%; padding: 8px;">
    </div>

    <div style="margin-bottom: 30px;">
      <label for="parents_nl"><strong>Zijn uw ouders in Nederland geboren?</strong></label>
      <select id="parents_nl" name="parents_nl" required onchange="document.getElementById('parents_nl_text').style.display = this.value === 'Nee' ? 'block' : 'none';" style="width: 100%; padding: 8px;">
        <option value="">-- Selecteer --</option>
        <option value="Ja">Ja</option>
        <option value="Nee">Nee</option>
      </select>
    </div>
    <div id="parents_nl_text" style="display: none; margin-bottom: 30px;">
      <label for="parents_nl_other"><strong>Waar zijn uw ouders geboren?</strong></label>
      <input type="text" id="parents_nl_other" name="parents_nl_other" style="width: 100%; padding: 8px;">
    </div>

    <div style="max-width: 700px; margin: 30px auto; font-size: 18px; text-align: center;">
      <label><strong>Gebruikt u Straattaal?</strong></label>
      <div style="display: flex; justify-content: center; gap: 30px; margin-top: 15px;">
        <label>
          <input type="radio" name="Straattaalspreker" value="Ja" required>
          Ja
        </label>
        <label>
          <input type="radio" name="Straattaalspreker" value="Nee">
          Nee
        </label>
      </div>
    </div>

    <div style="margin-bottom: 30px;">
      <label for="languages"><strong>Gesproken moedertalen:</strong></label>
      <textarea id="languages" name="languages" rows="3" placeholder="Bijv. Nederlands, Engels" style="width: 100%; padding: 8px;"></textarea>
    </div>
  `,
  button_label: "Voltooien"
};
