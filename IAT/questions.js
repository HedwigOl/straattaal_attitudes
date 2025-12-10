// --- QUESTIONS ---

// Words used in the IAT and included in the questionnaire as examples
const straattaalWords = "doekoe, waggie, osso, fittie, patta, pokoe"
const nederlandsWords = "auto, ruzie, liedje, schoen, geld, huis"

// Create explicit questionnaire with slider bars
function createSurveyBlock(languageLabel, example_words) {

  const questions = [
    `
    <p>Welke achtergrond associeert u met sprekers van <b>${languageLabel}</b>?</p>
    <div style="text-align:center;">
      <input type="range" name="Ethnicity_${languageLabel}" min="0" max="100" value="50" style="width:600px;">
      <div style="display:flex; justify-content:space-between; width:600px; margin:0 auto; font-size:14px;">
        <span>Met migratieachtergrond</span><span>Zonder migratieachtergrond</span>
      </div>
    </div>
    `,
    `
    <p>Welke geslacht associeert u met sprekers van <b>${languageLabel}</b>?</p>
    <div style="text-align:center;">
      <input type="range" name="Gender_${languageLabel}" min="0" max="100" value="50" style="width:600px;">
      <div style="display:flex; justify-content:space-between; width:600px; margin:0 auto; font-size:14px;">
        <span>Man</span><span>Vrouw</span>
      </div>
    </div>
    `,
    `
    <p>Welke leeftijd associeert u met sprekers van <b>${languageLabel}</b>?</p>
    <div style="text-align:center;">
      <input type="range" name="Age_${languageLabel}" min="0" max="100" value="50" style="width:600px;">
      <div style="display:flex; justify-content:space-between; width:600px; margin:0 auto; font-size:14px;">
        <span>Jong</span><span>Oud</span>
      </div>
    </div>
    `,
    `
    <p>Welke woonplek associeert u met sprekers van <b>${languageLabel}</b>?</p>
    <div style="text-align:center;">
      <input type="range" name="Location_${languageLabel}" min="0" max="100" value="50" style="width:600px;">
      <div style="display:flex; justify-content:space-between; width:600px; margin:0 auto; font-size:14px;">
        <span>Niet Randstad</span><span>Randstad</span>
      </div>
    </div>
    `,
    `
    <p>Welke sociale klasse associeert u met sprekers van <b>${languageLabel}</b>?</p>
    <div style="text-align:center;">
      <input type="range" name="Class_${languageLabel}" min="0" max="100" value="50" style="width:600px;">
      <div style="display:flex; justify-content:space-between; width:600px; margin:0 auto; font-size:14px;">
        <span>Lage klasse</span><span>Hoge klasse</span>
      </div>
    </div>
    `,
    `
    <p>Hoe staat u tegenover het gebruik van <b>${languageLabel}</b>?</p>
    <div style="text-align:center;">
      <input type="range" name="Rating_${languageLabel}" min="0" max="100" value="50" style="width:600px;">
      <div style="display:flex; justify-content:space-between; width:600px; margin:0 auto; font-size:14px;">
        <span>Negatief</span><span>Positief</span>
      </div>
    </div>
    `
  ];

  // Shuffle questions
  function shuffle(arr) {
    for (let i = arr.length - 1; i > 0; i--) {
      const j = Math.floor(Math.random() * (i + 1));
      [arr[i], arr[j]] = [arr[j], arr[i]];
    }
    return arr;
  }

  const shuffledQuestions = shuffle(questions);

  return {
    type: jsPsychSurveyHtmlForm,
    preamble: ` 
      ${style_UU}
      <div style="max-width: 800px; margin: 0 auto; font-size:18px;">
        <p><b>In hoeverre associeert u de volgende kenmerken met ${languageLabel} (woorden zoals: ${example_words}) en sprekers hiervan?</b></p>
        <p><i>Gebruik de schuifbalken: hoe dichter u bij één van de uitersten kiest, hoe sterker u dat kenmerk associeert met <b>${languageLabel}</b>.</i></p>
      </div>`,

    html: shuffledQuestions.join('') + `
      <hr style="border: none; border-top: 2px solid white; margin: 20px 0;">
    `
  };
}

// Create timeline for explicit questionnaire with randomized order of pages
let explicitQuestionnaire = {
  timeline: [createSurveyBlock("STRAATTAAL", straattaalWords), createSurveyBlock("STANDAARD NEDERLANDS", nederlandsWords)]
    .sort(() => Math.random() - 0.5)
};

// Demographics page 1 (age + gender + education + residence)
let demographics1 = {
  type: jsPsychSurveyHtmlForm,
  preamble: `
    ${style_UU}
    <div style="max-width: 800px; margin: 5px auto; font-size: 18px;">
      <h3 style="margin-bottom: 10px;">Vul onderstaande vragen over uzelf in:</h3>
    </div>
  `,
  html: `
    ${style_UU}
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

// Demograpics page 2 (country of origin + languages)
let demographics2 = {
  type: jsPsychSurveyHtmlForm,
  preamble: `
    ${style_UU}
    <div style="max-width: 800px; margin: 5px auto; font-size: 18px;">
      <h3 style="margin-bottom: 10px;">Vul onderstaande vragen over uzelf in:</h3>
    </div>
  `,
  html: `
    ${style_UU}
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
      <label><strong>Beschouwt u uzelf als een gebruiker van Straattaal?</strong></label>
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

    <div style="max-width: 700px; margin: 30px auto; font-size: 18px; text-align: center;">
      <label><strong>Heeft u ervaring met het doen van Implicit Association Tests (IATs)?</strong></label>
      <div style="display: flex; justify-content: center; gap: 30px; margin-top: 15px;">
        <label>
          <input type="radio" name="IAT_experience" value="Ja" required>
          Ja
        </label>
        <label>
          <input type="radio" name="IAT_experience" value="Nee">
          Nee
        </label>
      </div>
    </div>

    <div style="margin-bottom: 30px;">
      <label for="languages"><strong>Welke talen beschouwt u als uw thuistalen?</strong></label>
      <textarea id="languages" name="languages" rows="3" placeholder="Bijv. Nederlands, Engels" style="width: 100%; padding: 8px;"></textarea>
    </div>

  `,
  button_label: "Experiment voltooien"
};
