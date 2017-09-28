Presentazione progetto
======================

La mia idea è stata di ricreare una struttura ad “oggetti” propria dei linguaggi ad alto livello, in un linguaggio di basso livello come l’Assembly. Ho pensato di strutturare il progetto in due micro strutture, mantenendo però lato utente l’impressione che sia tutto gestito da un’unica procedura. Questo ha aiutato molto nell’organizzazione del lavoro e nella semplificazione del codice da scrivere, in quanto mi sono ritrovato in più momenti a sfruttare codice/procedure che avevo già preventivamente sviluppato.

Descrizione “classi”
====================

Come già detto in precedenza ho creato due “classi” che avranno il compito di gestire informazioni come un “object”, che nel mio caso si tratta di un insieme di referenze key/value, accessibili attraverso una stringa (un nome). Per fare un esempio è possibile creare la seguente struttura:
“MyObject”
-“property1”: 48939
-“property2”: *qui potrebbe essere salvato un indirizzo di memoria per esempio*
Parlando in modo generico, la struttura seguirà le seguenti regole:

<span> |l|l| </span> nome oggetto & max 16 bytes (max 16 char), no caratteri speciali, no stringa nulla
nome proprietà & come nome oggetto
valore & valore qualsiasi (max 1 word)

La classe Object si prenderà cura di gestire tutti gli oggetti creati, la classe AssociativeMemory di gestire le loro referenze key/value, associando una stringa ad un valore. *Ogni stringa (nome) all’interno dello stesso oggetto dovrà essere unica, così come unico dovrà essere il nome di ogni oggetto (almeno per ogni istanza, leggasi dopo)*.
Entrambe le classi hanno un canale di input e uno di output molto simile. In input avranno entrambe un codice numerico (in \$a0) che permettterà loro di comprendere l’operazione corretta da eseguire, oltre a vari altri parametri sui successivi registri \$a*n*. In output entrambe hanno la solita forma: \$v0 contiene il valore di ritorno (se presente), \$v1 il codice di errore della procedura (se possibile) con \$v1 \< 0 per errori nei dati di input e \$v1 \> 0 per errori nell’elaborazione.
Inoltre per comprendere meglio come lavorano le istanze di Object e AssociativeMemory è utile spiegare fin da ora che la classe AssociativeMemory durante la fase di inizializzazione alloca un vettore di 3 words contenente le informazioni sull’istanza appena creata (indirizzo iniziale array delle keys, indirizzo iniziale array di valori, lunghezza della memoria) e ne restituisce l’indirizzo (d’ora in avanti **“oggetto memoria”**). In questo modo con un solo indirizzo sarà possibile ottenere tutte le informazioni che saranno necessarie durante l’esecuzione della classe Object e di quella AssociativeMemory.
*Ogni classe lavora ad istanze, quindi sarà necessario dapprima inizializzare una o più istanze di quella classe, dopodichè lavorarci. Lavorare con la classe Object non necessita di aver pre-inizializzato istanze della classe AssociativeMemory.*

Object
------

La procedura Object gestisce in input un method code con cui comprenderà l’operazione da effettuare. Le fasi di vita sono essenzialmente due: inizializzazione, ed uso.
Durante la fase di inizializzazione, l’utente dovrà creare un’istanza della classe Object attraverso la chiamata a procedura della stessa con il method code opportuno. Questa inizializzerà un’associative memory apposita per contenere tutti gli oggetti dell’istanza in creazione, associando ai nomi degli oggetti rispettivamente le associative memory per le loro referenze proprietà-valore.
Durante la fase di uso vero e proprio l’utente dovrà essersi salvato il valore di ritorno dell’inizializzazione dell’istanza di Object (che è un **“oggetto memoria”**) per poter referenziare esattamente quell’istanza, aggiungendola come parametro ad ogni chiamata, oltre al method code che intende usare.
Di seguito una lista dei method code accettati e della loro descrizione di funzionamento:

<span> |c|c|p<span>11.2cm</span>| </span> **Code** & **Nome** & **Descrizione**
-2 & Get Objects & Restituisce l’array di nomi degli oggetti dell’istanza e la sua grandezza
-1 & Init library & Crea un’istanza di Object, restituendo un **“oggetto memoria”**
0 & Get & Restituisce il valore della proprietà specificata dell’oggetto selezionato
1 & Add & Aggiunge la proprietà specificata all’oggetto selezionato
2 & Delete & Elimina la proprietà dell’oggetto selezionato
3 & Set & Imposta un valore alla proprietà specificata dell’oggetto selezionato
4 & Copy & Copia le proprietà (e valori) da un oggetto origine ad uno destinazione
5 & Clone & Collega due oggetti alle stesse proprietà (due nomi, solito oggetto)
6 & Create & Crea un oggetto, specificato il nome
7 & Get Keys & Restituisce l’array di nomi delle proprietà di un oggetto e la sua grandezza
8 & Delete Object & Elimina la stringa che referenzia un oggetto (non l’oggetto stesso)

AssociativeMemory
-----------------

La procedura AssociativeMemory è del tutto analoga alla Object come fasi di vita e gestione input/output mentre ciò che cambia è lo scopo e la generalità dell’utilizzo. Mentre Object sfrutta l’AssociativeMemory (d’ora in avanti Ass.Mem.) per gestire ed indirizzare gli oggetti e le proprietà che l’utente crea e modifica, l’Ass.Mem. invece potrebbe essere usata in modo indipendente come gestore di memorie associative, in quanto non ha vincoli per la chiave (key/value, tranne la chiave nulla), ma è anche più a “basso livello” per cui un utilizzo diretto potrebbe risultare essere più complicato.
Durante la fase di inizializzazione viene invocato il metodo “alloc” che si preoccuperà di creare un **“oggetto memoria”** da restituire poi al chiamante.
Durante la fase di uso invece, dovrà essere aggiunto ai parametri l’**“oggetto memoria”** restituito con l’alloc (di cui sopra), oltre al codice dell’operazione da eseguire e ad eventuali parametri aggiuntivi.
Di seguito una lista degli op code accettati e della loro descrizione di funzionamento:

<span> |c|c|p<span>12cm</span>| </span> **Code** & **Nome** & **Descrizione**
-1 & Alloc & Crea un’istanza di Ass.Mem., restituendo un **“oggetto memoria”**
0 & Get & Restituisce il valore della chiave specificata
1 & Set & Imposta un valore alla chiave specificata
2 & Create & Aggiunge la chiave specificata all’istanza di Ass.Mem.
3 & Delete & Elimina la chiave specificata dall’istanza di Ass.Mem.
4 & Copy & Copia le chiavi (e i valori) da un’istanza di Ass.Mem. ad un’altra
5 & Reset & Resetta (a 0) tutti i valori di un’istanza di Ass.Mem. eliminando le sue chiavi

Note finali
===========

Dinamicità di Object
--------------------

La procedura Object di default inizializza sempre memorie associative capaci di contenere al massimo 8 elementi (8 oggetti e per ogni oggetto 8 proprietà). Ciononostante senza l’intervento esterno, nel caso si richieda maggiore memoria (ad esempio creando un oggetto aggiuntivo dopo averne già creati 8, o ancora aggiungendo un ulteriore proprietà ad un oggetto che già ne possiede 8), la procedura gestisce indipendentemente l’ampliamento di memoria necessario per contenere il nuovo elemento (oggetto o proprietà che sia), aggiungendo, sempre di default, ulteriori 8 spazi in memoria.
Ciò viene conseguito riallocando attraverso l’Ass.Mem una memoria di grandezza pari a quella precedente aggiunto 8, copiando il contenuto della vecchia memoria in quella nuova e aggiornando le informazioni dell’**“oggetto memoria”** precedente con quelle del nuovo. Vengono modificate le informazioni all’interno e non viene sostituito l’oggetto memoria poichè andando a clonare oggetti (due nomi che si riferiscono allo stesso oggetto) si sarebbe dovuto gestire il fatto che molteplici nomi avessero lo stesso **“oggetto memoria”**, andando a scorrere ogni volta fosse stato necessario tutta l’istanza Object.
*Ad esempio avendo un oggetto da 8 elementi referenziato da due nomi, andando ad aggiungere un ulteriore proprietà (indicando l’oggetto con uno dei due nomi possibili) sostituire completamente l’**“oggetto memoria”** avrebbe comportato la sua sostituzione per ogni nome associato a quell’oggetto. Andando però a modificare le informazioni all’interno, io faccio si che la clonazione abbia effetivamente sostituito l’oggetto memoria di un oggetto Destinazione con quello di un oggetto Origine, ma quando vado a modificare quell’**“oggetto memoria”** (a partire da uno dei due nomi) al suo interno, siccome referenziato da due oggetti, ad entrambi i nomi corrisponderà tale modifica.*

Copiatura di oggetti
--------------------

La procedura Object possiede un metodo “Copy” che permette di far si che un oggetto Destinazione abbia le stesse proprietà di uno Origine, senza che entrambi i nomi si riferiscano allo stesso oggetto fisico. Questo metodo sfrutta l’operazione “Copy” della procedura Ass.Mem., la quale però accetta di copiare due contenuti solo se la grandezza della memoria Destinazione è almeno tanto grande quanto quella di Origine (resettando a 0 eventuali spazi in eccesso). Perciò se il metodo “Copy” si accorge che l’oggetto destinazione non è abbastanza grande provvederà ad aumentare la sua memoria con il procedimento di cui sopra (“Dinamicità di Object”) andando però ad impostare la grandezza della memoria dell’oggetto Destinazione pari a quello di Origine e ritentando la copiatura.

Accesso ai dati e scelte funzionali
-----------------------------------

Sia la procedura Object che quella Ass.Mem possiedono due comandi “get” entrambi scelti con codice 0 per una facilità di utilizzo (in quanto prevedo siano fortemente utilizzati rispetto ad altri).
Anche la struttura in sè dei codici dei metodi della Object e della Ass.Mem non è casuale. Siccome permettono entrambe operazioni molto diverse tra loro che richiedono diversi parametri, ho fatto si che uguali combinazioni di parametri avessero codice numerico contiguo fra loro e una propria tipologia (es: due metodi che necessitano solo dell’istanza della libreria avranno codici contigui 4,5 o 6,7 etc., e stessa tipologia di metodo “A”, “B”, etc. *più dettagli sono presenti nei commenti sul codice sorgente*). Ciò permette una facilità di comprensione lato utente e una facilità di gestione del codice lato procedura, soprattutto quando si parla di parametri passati anche tramite stack.
La struttura attuale delle procedure agevola molto la modularità delle funzioni capace di implementare. Una volta costruita la base della procedura e determinati i canali di input e output (vedasi il discorso fatto per \$v0 valore di ritorno e \$v1 codice di errore eventuale, comuni ad entrambe le procedure), si possono iniziare ad aggiungere funzionalità sapendo che la procedura in sè permette di accedere a determinati dati e dovrà dare in output determinati valori.
E’ facilmente possibile scorrere gli oggetti di un’istanza o le proprietà di un oggetto (o combinare assieme le due cose) sfruttando il metodo “Get Object Names” o “Get Object Keys” che restituiscono gli array con i nomi di oggetti e proprietà rispettivamente, sapendo che ogni elemento dell’array è composto da 4 words e conoscendone la grandezza.
*Il codice sorgente inoltre è stato completamente commentato, ogni procedura e sotto procedura ha la sua intestazione con dati in input e dati in output, ed ogni sezione è stata spiegata.*
*Mi è stato fatto presente che sarebbe corretto mantenere la convenzione per cui la lettura e scrittura dallo stack comportino un suo ridimensionamento (push e pop). Il codice è stato rivisto per poter seguire al meglio la convenzione ma sono presenti casi (commentati appositamente) in cui ho ritenuto di non seguire tale convenzione, laddove il codice fosse abbastanza chiaro da comprendere il perchè o fosse evidente che ciò avrebbe implicato semplicemente un aggiunta di codice inutile in quanto sarebbe stato un push-pop continuo senza chiamate a procedura o salti o “branch” nel mezzo.*
