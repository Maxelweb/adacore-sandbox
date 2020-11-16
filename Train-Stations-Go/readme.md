# Train Stations and Commuters (Flipped Class exercise)

## Exercise

Realize a circular line metro service simulator

- `M > 1` train stations (along a circular line)
- `N > M` commuters who forever revolve around their duty cycle
- 1 commuter train with capacity `C < N` (no prebooking)

Commuter duty cycle is the following:

1. Home --> Nearest train station
2. --> Jump on first possible train
3. Train --> Work (working..)
4. Work --> Nearest train station
5. --> Jump on first possible train
6. Train --> Home (rest..)


## Ideas

- Circular lane with stations along, assuming the train keeps going in the same direction (~ while do)
- The train has no prebooking, so each commuters can get off the train or board when the train arrives to one station
- Each train station has a **FIFO queue** for commuters waiting to board the train
- Each commuter has 3 info:
	1. Origin (home location)
	2. Destination (work location)
	3. What has to do (work body)


## Algo's implementation example

### Resources

- **Commuters:** Alice(X,Z), Bob(X,Y), Charlie(Y,X), Diego(Y,Z), Erica(Y,X), Trump(Z,Y)
- **Stations:** X, Y, Z
- **Train capacity:** 3

### States

0. Train is empty and starts

Seat 1 | Seat 2 | Seat 3
--- | --- | ---
/ | - | -


1. Train is in X station; A,B are in queue; A,B board the train

Seat 1 | Seat 2 | Seat 3
--- | --- | ---
A | B | -


2. Train is in Y station, C,D,E are waiting; B get off the train; C,D board the train

Seat 1 | Seat 2 | Seat 3
--- | --- | ---
A | C | D


> Here, Erica has to wait since the capacity is over


3. Train is in Z station, T is waiting; A,D get off the train; T board the train

Seat 1 | Seat 2 | Seat 3
--- | --- | ---
T | C | - 


4. Train is in X station, // is waiting; C get off the train; // board the train

Seat 1 | Seat 2 | Seat 3
--- | --- | ---
T | - | - 


5. Train is in Y station, E,B is waiting; T get off the train; E,B board the train

Seat 1 | Seat 2 | Seat 3
--- | --- | ---
E | B | - 


> From now on, everyone is at work, and the algorithm continues to recover people in inverse order and bring them home


### Cases

- **Worst case**: each commuters has the same origin and the same destination; the train stations are more than 2. 
- **Good case**: each commuters have the destination immediatly after their origin. 

### Observation

- Assuming the train commuter know the current destination for each current passenger, it can choose his direction, maximizing the number of people getting off the train. 



## Algo pseudo code

```
// def.file

Routine r(name,origin,destination) do
	
	current_pos = origin

	request_requeue(origin) // waits in queue
	
	if (current_pos == destination) then
		work()
	end

	request_requeue(destination) // waits in queue

	if (current_pos == origin) then
		rest()
	end
end

Channel train(C);			
Queue<Routine> stations(M)(N); 	// M stations with each a N maximum queue capacity

```

```
// algo.file

Function request_requeue(station)
	stations(station).push_back()
end

Function drop_off_passengers(station)
	commuters = train.pops_for(station) // capacity is updated
	foreach commuters as commuter 
		commuter.current_pos = station
		stations(station).push_back(commuter)
	end
end

Function board_passengers(station)
	commuters = []
	for i = 0, i < train.availableCapacity, i++ then
		commuters += stations(station).pop()
	end
	foreach commuters as commuter 
		train.push_back(commuter)
	end
end

```


```
// main.file


stations(x).push_back( r(Alice, X, Y) );
stations(x).push_back( r(Bob, X, Z) );
// [...]

currentStation = 0;

while (true) do
	foreach(stations as s)
		currentStation = s;
		train.drop_off_passengers(s) 
		train.board_passengers(s)
	end
end

```