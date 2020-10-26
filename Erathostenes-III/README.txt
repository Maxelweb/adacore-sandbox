Per la terza volta, i moduli Main.adb, SoE.ads e SoE.adb costituiscono 
una ulteriore possibile realizzazione concorrente dell'algoritmo del 
"crivello di Eratostene".
Questa versione arricchisce l'utilizzo del modello sincrono a rendezvous
con un appropriato controllo sulla plausibilità della sincronizzazione. 
Questo arricchimento consente la corretta terminazione del programma.

I tre moduli hanno il seguente ruolo, rispettivamente:
- Main.adb : costituisce l'unità principale, la cui elaborazione ed attivazione
	dà il via all'elaborazione ed attivazione delle unità da essa incluse
	(ove l'inclusione è dichiarata mediante clausola "with ...")
- SoE.ads : costituisce la specifica (ossia la parte dichiarativa, priva di
	implementazione) del modulo che implementa l'algoritmo
- SoE.adb : costituisce la realizzazione della corrispondente specifica.

Per compilare, eseguire ed analizzare il programma, conviene
dotarsi dell'ambiente open-source GPS (vedi pagina del corso).
Invocare il comando 'GPS' sul documento *.gpr e successivamente il
comando di costruzione 'Build -> Make -> <nome-unità-principale>' 
tramite chiave F4. Se il documento *.gpr è ben formato, il comando produce 
l'eseguibile del sistema, la cui esecuzione può essere avviata tramite
comando 'Build -> Run -> <nome-eseguibile>'.

La versione eseguibile di tale programma viene anche prodotta invocando 
il comando "gnatmake Main" (con l'applicazione gnatmake presente nel
proprio PATH), ed eseguita lanciando il corrispondente programma Main,
come segue:
# gnatmake main
gcc -c main.adb
gcc -c soe.adb
gnatbind -x main.ali
gnatlink main.ali
# main
 5
 7
^C
#
