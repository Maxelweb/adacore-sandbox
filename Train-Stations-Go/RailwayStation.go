/**
@Title Railway Station - Exercise
@authors: Pozzan Paolo, Salvadore Nicola, Sciacco Mariano, Travasci Gianluca
@Description:
"
	Realize a circular line metro service simulator

	M > 1 train stations (along a circular line)
	N > M commuters who forever revolve around their duty cycle
	1 commuter train with capacity C < N (no prebooking)

	Commuter duty cycle is the following:

	1. Home --> Nearest train station
	2. --> Jump on first possible train
	3. Train --> Work (working..)
	4. Work --> Nearest train station
	5. --> Jump on first possible train
	6. Train --> Home (rest..)
"
*/

package main

import (
	"fmt"
	"sync"
	"time"
)

type Stazione struct {
	nome string            // Id Stazione
	coda chan *Viaggiatore // Coda dei viaggiatori in attesa
}

type Viaggiatore struct {
	nome             string    // Nome del viaggiatore
	partenza, arrivo string    // Nomi delle stazioni di partenza e arrivo
	attesa           int       // EXTRA: Attesa per lavoro e per casa
	notifica         chan bool // canale di notifica per salita/discesa
	colore           string    // EXTRA: solo per il terminale
}

type Treno struct {
	capienza int
	posti    []*Viaggiatore
}

func RoutineViaggiatore(persona *Viaggiatore, stazioni []*Stazione) {
	for {
		// Trova la stazione dove metterti in coda
		p := 0
		for i := 0; i < len(stazioni); i++ {
			if stazioni[i].nome == persona.partenza {
				p = i
				break
			}
		}
		fmt.Printf("%v %v raggiunge %v \n", persona.colore, persona.nome, stazioni[p].nome)
		stazioni[p].coda <- persona

		// Mettiti in coda stazione partenza
		<-persona.notifica
		fmt.Printf("%v %v sale a %v \n", persona.colore, persona.nome, stazioni[p].nome)

		// Attende una notifica di arrivo dal treno
		<-persona.notifica
		fmt.Printf("%v %v scende a %v \n", persona.colore, persona.nome, persona.arrivo)

		// Eseguo il lavoro o dormo (simulato con uno sleep)
		time.Sleep(time.Second * time.Duration(persona.attesa))
		// [...]

		// Scambio partenza - arrivo e ripeto il ciclo
		persona.partenza, persona.arrivo = persona.arrivo, persona.partenza
	}
}

func RoutineTreno(treno Treno, stazioni []*Stazione) {
	for {
		for i := 0; i < len(stazioni); i++ {

			// Assumiamo un tempo di percorrenza media e attendiamo
			time.Sleep(time.Second * 4)
			fmt.Printf("%v [TRENO] in arrivo a %v (%d/%d passeggeri) \n", "\033[37m", stazioni[i].nome, len(treno.posti), treno.capienza)

			// Lascia passeggeri alla stazione [i]
			for j := 0; j < len(treno.posti); j++ {
				if treno.posti[j].arrivo == stazioni[i].nome {
					treno.posti[j].notifica <- true
					treno.posti = append(treno.posti[:j], treno.posti[j+1:]...)
				}
			}

			// Prende passeggeri stazione[i]
		Load:
			for len(treno.posti) < treno.capienza {
				select {
				case person := <-stazioni[i].coda:
					person.notifica <- true
					treno.posti = append(treno.posti, person)
				default:
					break Load
				}
			}
		}
	}
}

func main() {

	// Assumiamo che le stazioni abbiano uno spazio per la coda molto ampio
	// per il distanziamento sociale (=100)

	// Canali che simulano una coda per le stazioni
	padovaChannel := make(chan *Viaggiatore, 100)
	pordenoneChannel := make(chan *Viaggiatore, 100)
	vicenzaChannel := make(chan *Viaggiatore, 100)
	veneziaChannel := make(chan *Viaggiatore, 100)
	rovigoChannel := make(chan *Viaggiatore, 100)
	bassanoChannel := make(chan *Viaggiatore, 100)

	// Stazioni
	Padova := Stazione{"Padova", padovaChannel}
	Pordenone := Stazione{"Pordenone", pordenoneChannel}
	Vicenza := Stazione{"Vicenza", vicenzaChannel}
	Venezia := Stazione{"Venezia", veneziaChannel}
	Rovigo := Stazione{"Rovigo", rovigoChannel}
	Bassano := Stazione{"Bassano", bassanoChannel}

	// Viaggiatori
	Sergio := Viaggiatore{"Sergio", "Padova", "Vicenza", 5, make(chan bool), "\033[31m"}
	Luca := Viaggiatore{"Luca", "Pordenone", "Vicenza", 10, make(chan bool), "\033[32m"}
	Matteo := Viaggiatore{"Matteo", "Padova", "Bassano", 11, make(chan bool), "\033[33m"}
	Marco := Viaggiatore{"Marco", "Vicenza", "Venezia", 7, make(chan bool), "\033[34m"}
	Luciana := Viaggiatore{"Luciana", "Rovigo", "Venezia", 20, make(chan bool), "\033[35m"}
	Gianni := Viaggiatore{"Gianni", "Venezia", "Pordenone", 3, make(chan bool), "\033[36m"}
	Caterina := Viaggiatore{"Caterina", "Bassano", "Rovigo", 13, make(chan bool), "\033[40m"}

	// Strutture dati con stazioni e viaggiatori
	stazioni := []*Stazione{&Padova, &Pordenone, &Vicenza, &Venezia, &Rovigo, &Bassano}
	viaggiatori := []*Viaggiatore{&Sergio, &Luca, &Matteo, &Marco, &Luciana, &Gianni, &Caterina}

	/* Inizializzo i Viaggiatori come goroutine */
	for _, viaggiatore := range viaggiatori {
		go RoutineViaggiatore(viaggiatore, stazioni)
	}

	// Treno
	treno := Treno{3, make([]*Viaggiatore, 0, 3)}
	go RoutineTreno(treno, stazioni)

	/* Caso EXTRA: 2 treni, dove il secondo treno parte dopo 6 secondi */
	/*
		time.Sleep(time.Second * 6)
		treno2 := Treno{2, make([]*Viaggiatore, 0, 2)}
		go RoutineTreno(treno2, stazioni)

	*/

	// Aspetto all'infinito
	var wg sync.WaitGroup
	wg.Add(1)
	wg.Wait()
}
