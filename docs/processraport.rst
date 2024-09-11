
Læsevejledning
------------------------

Indledning
------------------------
Denne procesrapport er skrevet i sammenhæng med svendeprøveprojektet på H6PD091124.

Procesraporten dækker udvikling af min selvstændige udgave af kortspillet Caravan (fra videospillet Fallout New Vegas).
Raporten inkluderer overvejelser vedrørende projektet teknologier og primære alternativer dertil.


Case Beskrivelse
------------------------
.. include:: case_beskrivelse.rst

..
    _:: Problemformulering er inkluderet i case_beskrivelse.rst, og er derfor ikke et kapitel her


Afgrænsning
------------------------


Estimeret Tidsplan
------------------------

Valg af teknologier
------------------------

Godot
^^^^^^^^^^^^^^^^^^^^^^^^^^
Som kerneteknologi for projektet ligger Godot,
som er et gratis, open-source, spiludviklingsværktøj.

Spil i Godot bygges som en sammensætning af _scener_, som i sig selv er en sammentætning af _noder_.
Noder kan være så simple som funktionsløse geometriske former, disse former kan både bruges i spilverdenen,
men kan også bruges til at konstruere den grafiske brugerflade.
Mere avancerede noder tilknyttes et script,
hvilket giver en stor liste af muligheder for hvordan denne node kommunikerer med,
og påvirkes af, andre noder i spillet.

Når noder sammensættes på en genbruglig måde, kan de gemmes som en scene

Godot supporterer programmering i flere forskellige sprog:

* GDScript
    Godot er selv skrevet i C++, men typisk skrives spil deri i deres scripting sprog GDScript.
    GDScript minder på mange måder om Python, potentielt blandet med lidt JavaScript.
    GDScript filer kendetegnes med filentypen .gd, og knyttes oftest direkte til såkaldte "Noder" i spillet.
    Når man knytter et .gd script til en node, bliver den node en instans af klassen som man definerer i .gd filen.

    Så trods det er svært at se i script filerne, er GDScript meget objektorienteret.
    Hver .gd script udgør præcis én klasse, hvilket bliver meget tydligere at se hvis man inkluderer nøgleordet "class_name <Name>" deri.

    GDScript har dog sine begrænsninger i forhold til de traditionelle objektorienteret programmeringssprog.
    Ligevidt som C# og Java, understøtter GDScript _ikke_ multipel nedarvning. Dette faktum overkommer C# og Java med interfaces.
    GDScript har dog ikke interfaces, i den traditionelle forstand,
    og afhænger i stedet af "duck typing" til at løse mere indviklede nedarvningshierarkier.

* C#
    Som de primære alternativ til GDScript, tilbyder Godot også et C# API.
    C# APIet ser stærkt støtte fra Godot's udviklere,
    men nogle enkelte mangler viser at GDScript stadig har førsteprioritet.

    C# API'et er dog nok stadig et godt valg, når man vil prioritere ydeevne og en skalérbar kodebase.
    Men med Caravan's lave krav om ydeevne, og med mit ønske om at køre spillet på flere platforme,
    følte jeg det mere passende at forblive uafhængig af en .NET runtime.
    Her skal jeg dog nævne at det, efter min forståelse,
    er muligt at eksportere sit Godot/C# spil med en Mono runtime inkluderet.

    Mono er en open-source implementation af .NET standarden,
    som med årene har set mere støtte fra Microsoft.


    Min personlige holdning af C# har ændret sig meget i løbet af min uddannelse som Datatekniker.
    I den tid jeg har været elev der, har Tech College været stærkt integreret med Microsoft økosystemet.
    .NET sprogene har derfor, naturligvis, haft førsteprioritet.
    Derfor startede min viden om programmering med C#,
    hvor det fandt det utroligt at sproget kunne skrive "Hello World!" i mit konsolvindue.
    Efter omkring et halvt år på GF1 havde jeg langsomt begyndt at forstå fidusen bag Objektorienteret Programmering,
    men jeg undrede mig stadig over "static void Main(string[] args)".
    For mig passede nøgleordet "static" ikke ind i et objektorienteret programmeringssprog.
    Hvorfor skal jeg definere "class Program {...}", når "static void Main(string[] args)" ikke er bundet til nogen instans deraf?

    Herefter blev jeg introduceret til Python, og var totalt forbløffet over hvor nemt alting var.
    Det føltes som om jeg blev givet snyderkoder.
    Python er også lidt speciel i den forstand at det understøtter Objektorienteret Programmering,
    men det er ikke et krav.
    Og for mig gav det bare meget mere mening. Intet magisk "this" nøgleord, i stedet har du "self",
    som blot er en reference til en instans af klassen hvorpå metoden er defineret.
    Funktioner er ikke knyttet nogen instans, er har derfor hverken "this" eller "self".
    Samtidig gav det også bare meget mere mening at koden eksekverer fra toppen,
    linking og symbol afvikling er meget nemmere at forstå,
    når man kan sætte et breakpoint i sit script og se hvordan/hvornår symboler opdages.

    I starten kendte jeg ikke til Python's type-hinting syntax,
    så selvfølgelig brugte jeg det heller ikke.
    Men jeg var så glad for Python, at jeg ville simpelthen bare lære alt om sproget.
    Så det varede ikke længe inden alle mine variable havde type-hints.
    Et faktum som også gjorde PyCharm's liv meget nemmere, for ikke at tale om mit eget.
    De gjorde det meget nemmere at knytte APIer i mere komplekse programmer.

    Det var nok heromkring hvor jeg begyndte at tilgive C#.
    Det betyder ikke at jeg har tænkt mig at kode i sproget.
    Jeg har arbejdet utroligt meget med generics og reflection i Python,
    hvor C#'s reflection wrapper API utroligt klodset forholdsvis.
    Og jeg fandt heller ikke skolens introduktion til Entity Framework specialt imponerende,
    efter at have arbejdet med Django's ORM.


* C/C++
    Som sagt er Godot selv skrevet i C++, det er derfor naturligt af de tilbyder et API til dynamisk linking af biblioteker.

    Eftersom at Godot er open-source, kan man også skrive sine udvidelser/rettelser direkte i kildekoden.
    Dette kræver dog en rekompilering af selveste Godot, hvilket kan gøre udviklingen væsentligt mere tidskrævende.

    Allerede inden opstart af projektet var jeg ude og undersøge Godot's udviklingsmuligheder indenfor C/C++.
    Min tid ved Space Inventor har jeg gjort godt tilpas med C, og jeg så det derfor, på daværende tidspunkt,
    som en fin udfordring at bruge den viden til projektet.
    Men jeg ombestemte mig ved næremere eftertanke,
    da jeg så det som en højere prioritet at udvikle spillet på en cross-platform manér.
    Det er nemlig min forståelse at brugen af C/C++ APIerne udfordrer Godot's lange række af indbyggede cross-platform eksporteringsmuligheder.

Det kan dog siges at Godot lever i skyggen af sine væsentligt mere velkendte konkurrenter: Unity og Unreal.
Godot så dog et stort fremspring af både financial og moralsk støtte,
da Unity indførte en række kontroversielle ændringer til deres servicevilkår i Q4 af 2023.

For mig var én af Godot's store salgspunkter muligheden for at eksportere til HTML5.
Jeg ser det som en kæmpe fordel at kunne hoste spillet som en server,
og blot inkludere et link dertil i disse rapporter.

** Alternativer **

# Unity
    Unity står som én af de 2 kæmper inden for spiludviklingsværktøjer.
    Og trods de tidligere nævnte kontroversielle ændringer til deres servicevilkår i Q4 af 2023,
    er Unity stadig ofte brugt til udvikling af mere krævende spil.
    Unity's omry er også som mere begyndervenlig end Unreal.

    Unity spil skrives i C#, og er derfor afhængig af en .NET runtime.
    Denne afhængighed tillader dem dog at køre på på flere platforme.

    Unity er gratis til udvikling af ikke-kommericelle spil.

# Unreal
    Unreal står som den anden kæmpe af spiludviklingsværktøjer.

    Unreal's omry er som mere avanceret end Unity.
    Dette giver muligheder for bedre ydeevne, men gør også værktøjet mindre begyndervenligt.

    Som hjemmel til det skræmmende omry skrives Unreal spil, som udgangspunkt, i C/C++.
    Men som alternativ hertil tilbyder Unreal deres grafiske programmeringsværktøj "Blueprints":

    .. image:: Unreal_Blueprints.png

    kilde: https://dev.epicgames.com/documentation/en-us/unreal-engine/blueprints-quick-start-guide?application_version=4.27


Docker
^^^^^^^^^^^^^^^^^^^^^^^^^^


Database
^^^^^^^^^^^^^^^^^^^^^^^^^^


Alternativer
^^^^^^^^^^^^^^^^^^^^^^^^^^

Realiseret tidsplan
------------------------


Konklusion
------------------------


Refleksioner
^^^^^^^^^^^^^^^^^^^^^^^^^^
