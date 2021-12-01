# ElasticSearch
*A ElasticSearch client for Julia*

## Installation

This package is not currently registered in the [`General`](https://github.com/JuliaRegistries/General)，so you must use github repository address to install

```julia
julia> ]
pkg> add https://github.com/lotcher/ElasticSearch.jl.git
```

## usage

Before using all methods, you need to create an ES instance, like this

```julia
using ElasticSearch
es = ES()  # ES("http://:@localhost:9200")

# You can use this method: ES(; host, port, user, password, protocol) to construct the client you need, or directly pass in the complete URL like ES("https://elastic:elastic@localhost:9300")
```

### search

You can use the **search** method to pass in JSON, Dict or built-in query objects

```julia
search(es, 'index', "{}")  # be equal to GET /index/_search  body={}

# You can also pass in other objects
# search(es, 'index', Dict())
# search(es, 'index', Query([]))
```

However, when you use complex query statements, it is recommended to use query, as shown below

```Julia	
search(es=es, index="news") do
        [
            FromBlock(0),
            SizeBlock(10),
            [
                RangeBody("correlation", Dict("gte"=>0.5)),
                RangeBody("emotion", Dict("gte"=>0.5)),
                MultiMatchBody(["contents","title"], "test")
            ] |> MustQueryBlock,
            HighlightBlock(["contents","title"]),
            SourceBlock(["img_urls","id","time","title","url"])
        ] |> Query
```

It is equivalent to constructing the following query statements. 

```json
GET news/_Search
{
  "size": 10,
  "from": 0,
  "query": {
    "bool": {
      "must": [
        {
          "range": {
            "correlation": {
              "gte": 0.5
            }
          }
        },
        {
          "range": {
            "emotion": {
              "gte": 0.5
            }
          }
        },
        {
          "multi_match": {
            "fields": [
              "contents",
              "title"
            ],
            "query": "test"
          }
        }
      ]
    }
  },
  "highlight": {
    "fields": {
      "correlation": {},
      "emotion": {}
    }
  },
  "_source": [
    "img_urls",
    "id",
    "time",
    "title",
    "url"
  ]
}
```

Similarly, you can also construct any ES DSL statements with built-in objects

