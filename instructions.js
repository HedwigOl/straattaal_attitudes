// --- INSTRUCTIONS ---

const information_letter_1 =
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
      In dit deel zult u in verschillende rondes woorden en namen in twee groepen moeten classificeren
      (max. 4 minuten). In het tweede deel krijgt u enkele vragen over uzelf en over wat u van Straattaal
      vindt (max. 2 minuten).<br>
      Deelname aan dit onderzoek is volledig vrijwillig en u kunt op elk moment besluiten om niet deel te nemen
      of uw deelname te beëindigen, zonder opgaaf van reden en zonder nadelige gevolgen.</p>
    </div>`

const information_letter_2 = 
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
      verschillende groepen. We begrijpen dat dit een gevoelig onderwerp kan zijn. Alle gegevens worden 
      vertrouwelijk behandeld, veilig opgeslagen en alleen in geanonimiseerde vorm gebruikt, zodat niemand 
      individueel te herleiden is. </p>

      <h3>Vragen en klachten</h3>
      <p>Heeft u na het lezen van deze informatiebrief nog vragen over uw deelname? Neem dan gerust contact op
      met Hedwig Oldenhof via <a href="mailto:h.oldenhof@uu.nl">h.oldenhof@uu.nl</a>.<br>
      Als u een klacht heeft over dit onderzoek, kunt u een e-mail sturen naar
      <a href="mailto:etc-beta-geo@uu.nl">etc-beta-geo@uu.nl</a>. U komt dan in contact met een onafhankelijke
      contactpersoon die niet betrokken is bij dit onderzoek en uw klacht zorgvuldig zal behandelen.<br>
      Heeft u vragen of zorgen over uw privacy binnen dit project? Neem dan contact op via
      <a href="mailto:privacy-beta@uu.nl">privacy-beta@uu.nl</a>.</p>
    </div>`

const consent_text = 
    `<div class="instruction">
      <img src="https://www.uu.nl/sites/default/files/styles/original_image/public/uu-logo-en-geenwitruimte.png" 
           alt="UU logo" 
           style="width:200px; margin-right:20px; margin-top:20px;">      
      <p>Door op de knop “Ik ga akkoord” te klikken, bevestig ik mijn vrijwillige deelname aan het project
      <i>“Taalattitudes van LLMs”</i> en verklaar ik het volgende:</p>
      <ul>
        <li> Ik heb de informatiebrief over het onderzoek zorgvuldig gelezen.</li>
        <li> Ik weet dat ik de onderzoeker kan bereiken met vragen over de studie via <a href="mailto:h.oldenhof@uu.nl">h.oldenhof@uu.nl</a>.</li>
        <li> Ik weet dat ik klachten over de studie kan indienen bij de ethische commissie van de Universiteit Utrecht (<a href="mailto:etc-beta-geo@uu.nl">etc-beta-geo@uu.nl</a>).</li>
        <li> Ik begrijp dat mijn deelname volledig vrijwillig is en dat ik op elk moment mag besluiten om niet deel te nemen of mijn deelname te beëindigen, zonder opgaaf van reden en zonder nadelige gevolgen.</li>
        <li> Ik geef toestemming voor de verwerking van mijn gegevens, mits deze anoniem of gecodeerd worden verwerkt, zoals toegelicht in de informatiebrief.</li>
        <li> Ik ga ermee akkoord dat deze geanonimiseerde data openlijk beschikbaar zal zijn voor de wetenschappelijke gemeenschap en minimaal tien jaar bewaard zal blijven.</li>
      </ul>
    </div>`

const no_consent = 
    `<div class = "instruction center-text">
      <p>Omdat u niet wilt deelnemen aan dit onderzoek, vragen wij u deze vragenlijst te sluiten en uw inzending op Prolific af te ronden door op de knop ‘Stoppen zonder te voltooien’ te klikken.</p>
    </div>`

const instruction_demographics = 
    `<h3>Demografische gegevens</h3>
    <p>Vul alstublieft de volgende informatie in:</p>`

const end_experiment = 
    `<div class = "instruction center-text">
      <h3>Bedankt voor uw deelname!</h3>
      <p>Klik op de onderstaande knop om terug te gaan naar Prolific en uw deelname te registreren.</p>
    </div>`

