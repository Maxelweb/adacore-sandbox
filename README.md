# adacore-sandbox

AdaCore Sandbox for Runtimes for Concurrency and Distribution

---

### Crivello di Eratostene

Crivello --> Setaccio, ossia Filtro

L'algoritmo prende in input un numero (n) e restituire una sequenza di numeri primi fino a quel numero.

1) Inizio partendo dal numero più piccolo (2) e rimuovo tutti i numeri successivi che sono divisibili nell'intervallo fino a n.
2) Continuo il procedimento con tutti i numeri successivi a 2 fintanto che il quadrato del numero preso in esame è `< n`
3) Ho una serie di numeri primi a 2 a N.


- Algoritmo a discesa ricorsivo
	- *Primo passaggio ricorsivo:* il numero sotto esame è divisibile per 3? 

	- *Passaggi ricorsivi successivi:* Ogni numero che entra si controlla se è divisibile per i numeri precedenti già trovati. 
		--> Non è divisile per i numeri primi conosciuti fino ad adesso.
		--> A ogni chiamata non so subito la risposta, il filtro conosce sé stesso e basta
		--> Ciascuno risponde a una sola domanda, quando finisce in fondo si trova la risposta.
	
- Come ci si fa a fermare?
	- La ricorsione si interrompe quando il numero filtro sa che non c'è un successore.


### Crivello di Eratostene con Thread Concorrenti

- Ogni filtro è un thread. 
- Come creare la chiamata ricorsiva? Partendo dal filtro più alto (nello stack) e al filtro più in basso (il numero 3), avrò la risposta se quel numero nel filtro corrente è primo.
- La procedura chiama sé stessa, a meno che non ci sia un next.
	--> Nel runtime aggiungo un filtro nello stack
	--> Chiedo e rispondo in modo sincronizzato su ogni numero

- Chiamo - Risposta in una procedura ricorsivo
- Traponendo nei thread, Chiamo, Risposta (se lo divido, allora no, altrimenti creo un thread per prepare il filtro di quel numero e attendo il prossimo numero che scenderà.)


- Nei thread? Il thread deve fare il suo lavoro e crea altri thread in annidamento.
	--> Il main quindi sarà a conoscenza solo del thread che ha il filtro 3. Tutti gli altri verranno creati (fork) per i successori.

- Il server non termina arbitrariamente e sapere che non ci sono più client non è una cosa fattibile.
- Le soluzioni da trovare per capire quando termina il programma devono essere SCALABILI e GENERALI.
- Realizzare concorrenza collaborativa per scambio messaggi implica il fatto di togliere visibilità al main, usando come soluzione i thread annidati. Inoltre, ciascun thread non può terminare arbitrariamente, perché farebbe danno ai client che nel mondo stanno vedendo quel "canale". Ma al contempo il programma non terminerebbe mai.

### Ada

- ADS: specification (firme)
- ADB: body (implementazione)

### Programma 

- *main:* richiede solamente il numero massimo limite
- *soe:* 
	- ha un task (tipo thread, senza la keyword `type` perché è un singleton, ossia una sola istanza) chiamato `odd` per inserire il limite massimo; presente `entry` dentro `odd` che verrà inserita dal main.
	- ha un insieme di task `Sieve_T` 

Nel dettaglio `Sieve_Ref` è un puntatore a istanze di `Sieve_T`. 

La prima cosa che fa `Odd` è una receive (`accept`, linea 40) e passa i numeri dispari al crivello.
`New_Sieve` crea un runtime di un certo tipo nell'heap, ed è inevitabile che sia lì, perché in altri luoghi non ci sarebbe più. In questo modo ho il riferimento del proprio task e il singolo thread.  

L'`end` alla riga 57 è un coend, perché si mantiene in vita per conoscere gli altri crivelli.

Alla riga 106, viene creato un nuovo Sieve se il numero non è divisibile. Alla riga 122 il programma viene terminato. 
Fintanto che qualcuno ha in "pancia" un thread non può eseguire `terminate`. 

## Esercizio

Provare a capire il senso dell'ordine dei Sieve e provare a togliere i `terminate`.

- Togliendo `or terminate`, Il programma non termina e rimane sempre attivo.

