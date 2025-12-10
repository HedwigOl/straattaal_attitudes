// --- INSTRUCTIONS ---

// Part 1 of the information letter
const informationLetter1 =
    `<div class = "instruction">
      <img src="https://www.uu.nl/sites/default/files/styles/original_image/public/uu-logo-en-geenwitruimte.png" 
           alt="UU logo" 
           style="width:200px; margin-right:20px; margin-top:20px;">
      
      <p>U staat op het punt om mee te doen aan een experiment dat onderdeel is van het onderzoeksproject
      <i>“Taalattitudes van LLMs”</i>.</p>

      <h3>Wat is het doel van dit onderzoek?</h3>
      <p>In dit project onderzoeken we of de associaties die taalmodellen met verschillende taalvariëteiten
      hebben, overeenkomen met de associaties van mensen. Dit experiment heeft als doel te onderzoeken welke
      associaties mensen hebben met Straattaal en Straattaalsprekers.</p>

      <h3>Hoe verloopt het experiment?</h3>
      <p>Het experiment bestaat uit twee delen. Na het accepteren van de voorwaarden begint het eerste deel.
      In dit deel zult u in verschillende rondes woorden en namen in twee groepen moeten categoriseren
      (max. 8 minuten). In het tweede deel krijgt u enkele vragen over uzelf en over uw associaties met Straattaal en Straattaalsprekers
       (max. 2 minuten).<br>
      Deelname aan dit onderzoek is volledig vrijwillig en u kunt op elk moment besluiten om niet deel te nemen
      of uw deelname te beëindigen, zonder opgaaf van reden en zonder nadelige gevolgen.</p>
    </div>`

// Part 2 of the information letter    
const informationLetter2 = 
    `<div class = "instruction">
      <img src="https://www.uu.nl/sites/default/files/styles/original_image/public/uu-logo-en-geenwitruimte.png" 
           alt="UU logo" 
           style="width:200px; margin-right:20px; margin-top:20px;">      
      <h3>Hoe wordt mijn data verwerkt?</h3>
      <p>In dit experiment worden uw reactietijden en de correctheid van uw antwoorden opgeslagen, net als uw
      antwoorden op de vragenlijst van het tweede deel van het experiment. Identificatiegegevens worden direct
      verwijderd zodra ze zijn verwerkt. Het databestand zal dus geen directe identificatie gegevens bevatten.
      Het geanonimiseerde databestand wordt opgeslagen op Yoda, een beveiligd digitaal systeem van de Universiteit
      Utrecht. Nederlandse universiteiten zijn overeengekomen deze gegevens minimaal 10 jaar te bewaren. Ook zal
      de data openbaar gemaakt worden voor de wetenschappelijke gemeenschap, zodat andere onderzoekers de
      geldigheid van ons onderzoek kunnen controleren.</p>
      <p>In deze studie vragen we naast uw demografische gegevens ook naar uw etnische achtergrond. 
      Deze informatie helpt ons te begrijpen of uitkomsten, ervaringen of reacties verschillen tussen 
      verschillende groepen. We begrijpen dat dit een gevoelig onderwerp kan zijn. <b> Alle gegevens worden 
      vertrouwelijk behandeld, veilig opgeslagen en alleen in geanonimiseerde vorm gebruikt, zodat niemand 
      individueel te herleiden is. </b> </p>

      <h3>Vragen en klachten</h3>
      <p>Heeft u na het lezen van deze informatiebrief nog vragen over uw deelname? Neem dan gerust contact op
      met Hedwig Oldenhof via <a href="mailto:h.oldenhof@students.uu.nl">h.oldenhof@students.uu.nl</a>.<br>
      Als u een klacht heeft over dit onderzoek, kunt u een e-mail sturen naar
      <a href="mailto:etc-beta-geo@uu.nl">etc-beta-geo@uu.nl</a>. U komt dan in contact met een onafhankelijke
      contactpersoon die niet betrokken is bij dit onderzoek en uw klacht zorgvuldig zal behandelen.<br>
      Heeft u vragen of zorgen over uw privacy binnen dit project? Neem dan contact op via
      <a href="mailto:privacy-beta@uu.nl">privacy-beta@uu.nl</a>.</p>
    </div>`

// Informed consent checklist
const consentText = 
    `<div class="instruction">
      <img src="https://www.uu.nl/sites/default/files/styles/original_image/public/uu-logo-en-geenwitruimte.png" 
           alt="UU logo" 
           style="width:200px; margin-right:20px; margin-top:20px;">      
      <p>Door op de knop “Ik ga akkoord” te klikken, bevestig ik mijn vrijwillige deelname aan het project
      <i>“Taalattitudes van LLMs”</i> en verklaar ik het volgende:</p>
      <ul>
        <li> Ik heb de informatiebrief over het onderzoek zorgvuldig gelezen.</li>
        <li> Ik weet dat ik de onderzoeker kan bereiken met vragen over de studie via <a href="mailto:h.oldenhof@students.uu.nl">h.oldenhof@students.uu.nl</a>.</li>
        <li> Ik weet dat ik klachten over de studie kan indienen bij de ethische commissie van de Universiteit Utrecht (<a href="mailto:etc-beta-geo@uu.nl">etc-beta-geo@uu.nl</a>).</li>
        <li> Ik begrijp dat mijn deelname volledig vrijwillig is en dat ik op elk moment mag besluiten om niet deel te nemen of mijn deelname te beëindigen, zonder opgaaf van reden en zonder nadelige gevolgen.</li>
        <li> Ik geef toestemming voor de verwerking van mijn gegevens, mits deze anoniem of gecodeerd worden verwerkt, zoals toegelicht in de informatiebrief.</li>
        <li> Ik ga ermee akkoord dat deze geanonimiseerde data openlijk beschikbaar zal zijn voor de wetenschappelijke gemeenschap en minimaal tien jaar bewaard zal blijven.</li>
      </ul>
    </div>`

// Text when no consent is given    
const noConsent = 
    `<div class = "instruction center-text">
      <p>Omdat u niet wilt deelnemen aan dit onderzoek, vragen wij u deze vragenlijst te sluiten en uw inzending op Prolific af te ronden door op de knop <strong>‘Stoppen zonder te voltooien’</strong> te klikken.</p>
    </div>`

// General instruction of the IAT    
const iatInstructions = 
    `<div style="max-width:900px; margin:auto; font-family:sans-serif; text-align:left;">
      <p style="font-size:1.2rem;">
        In het eerste deel van dit experiment zult u steeds woorden en namen zo snel en correct mogelijk categoriseren met behulp van de <b>'f'</b> en <b>'j'</b> toetsen.
        Dit zijn de vier categoriën en de woorden of namen die bij iedere categorie horen:
      </p>

      <table style="width:100%; border-collapse:collapse; font-size:1rem; margin:20px 0;">
        <thead>
          <tr style="background:#f5f5f5;">
            <th style="border:1px solid #ccc; padding:8px; width:30%;">Categorie</th>
            <th style="border:1px solid #ccc; padding:8px;">Items</th>
          </tr>
        </thead>
        <tbody>
          <tr>
            <td style="border:1px solid #ccc; padding:8px;"><b>Straattaal</b></td>
            <td style="border:1px solid #ccc; padding:8px;">doekoe, fittie, osso, waggie, pokoe, patta</td>
          </tr>
          <tr>
            <td style="border:1px solid #ccc; padding:8px;"><b>Standaardnederlands</b></td>
            <td style="border:1px solid #ccc; padding:8px;">geld, ruzie, huis, auto, liedje, schoen</td>
          </tr>
                    <tr>
            <td style="border:1px solid #ccc; padding:8px;"><b>Met migratieachtergrond</b></td>
            <td style="border:1px solid #ccc; padding:8px;">Amira, Fatma, Samira, Salma, Mohamed, Ayoub, Murat, Ilias</td>
          </tr>
          <tr>
            <td style="border:1px solid #ccc; padding:8px;"><b>Zonder migratieachtergrond</b></td>
            <td style="border:1px solid #ccc; padding:8px;">Anne, Esther, Julia, Laura, Martijn, Dennis, Jesse, Thomas</td>
          </tr>
        </tbody>
      </table>

      <p style="font-size:1.1rem;">
        Dit experiment bestaat uit vijf onderdelen. De instructies veranderen voor ieder deel. <b>Dus let goed op!</b>
      </p>
    </div>
  `

// Environment checklist
const environmentText = `
<div style="max-width: 700px; margin: 0 auto; text-align: left; line-height: 1.6;">
  <p><strong>Om ervoor te zorgen dat de resultaten van dit experiment zo nauwkeurig mogelijk zijn, vragen wij u het volgende te doen:</strong></p>

  <ul>
    <li>Zorg dat u zich bevindt in een rustige omgeving.</li>
    <li>Minimaliseer eventuele afleiding (zorg dat u alleen in een ruimte bent en zet bijvoorbeeld uw telefoon op stil of uit).</li>
    <li>Gebruik een QWERTY-toetsenbord.</li>
    <li>Sluit alle overige tabbladen en programma's op uw computer zodat de reactietijden zo precies mogelijk gemeten kunnen worden.</li>
  </ul>
  </div>
  `

// Create specific IAT instruction for each block
function blockInstruction(leftCategories, rightCategories, partNumber) {
  return `
    <div style="position: relative; font-size: 18px; width: 900px; margin: auto; padding: 20px;">

      <div style="display: flex; justify-content: center; gap: 400px; font-size: 18px; line-height: 1; margin-top: 80px;">
        <div style="text-align:center;">
          <p>Druk 'f' voor:</p>
          ${colorLabels(leftCategories).join(" <br>+<br> ")}
        </div>
        <div style="text-align:center;">
          <p>Druk 'j' voor:</p>
          ${colorLabels(rightCategories).join(" <br>+<br> ")}
        </div>
      </div>

      <br><br>

      <div style="text-align: center; font-size: 18px;">
        <u>Deel ${partNumber} van 5</u>
      </div>

      <br>

      <div style="font-size: 18px; line-height: 1;">
        ${partNumber === 3 || partNumber === 5 ? `<p><b>Bij dit volgende deel krijgt u steeds afwisselend woorden en namen te zien.</b></p>` : ""}
        <p>Druk met uw linkervinger op de <b>f</b>-toets voor items die behoren tot de categorie ${colorLabels(leftCategories).join(" + ")}.</p>
        <p>Druk met uw rechtervinger op de <b>j</b>-toets voor items die behoren tot de categorie ${colorLabels(rightCategories).join(" + ")}. De items verschijnen één voor één.</p>
        ${partNumber === 4 ? `<p><b>Let op: de toetsen van de twee categoriën zijn nu dus omgedraaid.</b></p>` : ""}
        <p>Als u een fout maakt, verschijnt er een rood <span style="color:red; font-weight:bold;">X</span>. Druk dan op de andere toets om verder te gaan.</p>
        <p><u>Probeer steeds zo snel mogelijk te antwoorden</u> terwijl u nauwkeurig blijft.</p>
      </div>

      <br><br>

      <div style="text-align: center; font-size: 20px;">
        Druk op de <b>spatiebalk</b> wanneer u klaar bent om te beginnen.
      </div>

    </div>
  `;
}

// Text when experiment has ended
const endExperiment = 
    `<div class = "instruction center-text">
      <h3>Bedankt voor uw deelname!</h3>
      <p>Klik op de onderstaande knop om terug te gaan naar Prolific en uw deelname te registreren.</p>
    </div>`
