collections-remote
====

abstraction layer between node-collections and concrete communication protocols.


expects one query - multiple replies + explicit end_of_reply style communication protocols, 

it can work naturally on top of http for example, for stream protocols it needs another layer that impelements query-reply system

