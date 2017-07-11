# RTriples

Simple but powerful RDF graph store based on awesome [RethinkDB database](http://www.rethinkdb.com/) & [Ruby](https://www.ruby-lang.org/) projects like [Sinatra](https://github.com/sinatra/sinatra).


## Installation

```
git clone https://github.com/lszeremeta/RTriples.git
cd RTriples
bundle
```

_Note_: RethinkDB must be [installed](http://www.rethinkdb.com/docs/install/) and [started](http://www.rethinkdb.com/docs/start-a-server/).

Now you may need to import some triples to RethinkDB ([RDF/JSON serialization](http://www.w3.org/2009/12/rdf-ws/papers/ws02)). You can simply generate it through [bsbmtools-json](https://github.com/lszeremeta/bsbmtools-json) or just use one of [generated samples](https://github.com/lszeremeta/bsbmtools-json-samples).

After that, import this data to RethinkDB:

```
rethinkdb import -f 100.json --table rtriples.100
```

That's all.

## Running client

You now need another simple step to start the client:

```
rackup -E production
```

Advanced options:

```
rackup [-E development|production] [-p PORT]
```

## Example usage

```
http://localhost:9292/?s=&p=&o=http://www4.wiwiss.fu-berlin.de/bizer/bsbm/v01/instances/ProductFeature179
```

or simply:

```
http://localhost:9292/?o=http://www4.wiwiss.fu-berlin.de/bizer/bsbm/v01/instances/ProductFeature179
```

returns HTML table with subjects and predicates related to object.

## Available params

* ```s``` - subject value (default: _nothing_)
* ```p``` - predicate value (default: _nothing_)
* ```o``` - object value (default: _nothing_)
* ```type``` - object type (default: ```uri```; other options: ```literal```, ```typed-literal```)
* ```lang``` - object language (default: _nothing_; allowed only if ```type``` is ```literal```)
* ```datatype``` - object datatype (default: _nothing_; allowed only if ```type``` is ```typed-literal```)
* ```limit``` - results limit (default: ```10```)
* ```format``` - output format (default: ```html```; other options: ```json```, ```nt```, ```csv```, ```txt```)

## Output formats

Client returns results as HTML table by default, but you can change it!

Specify the output format using ```format``` parameter:
* ```json``` - [RDF/JSON](http://www.w3.org/2009/12/rdf-ws/papers/ws02)
* ```nt``` - [N-Triples](http://www.w3.org/TR/n-triples/)
* ```csv``` - [Comma-Separated Values (CSV) file](https://tools.ietf.org/html/rfc4180)
* ```txt``` - simple text document output
* ```html``` - standard HTML table (default option)

## License
Distributed under [MIT license](https://github.com/lszeremeta/RTriples/blob/master/LICENSE.txt).
