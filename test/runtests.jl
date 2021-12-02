import Pkg
Pkg.activate(".")
using ElasticSearch
using Test, JSON


@testset "ElasticSearch.jl" begin
      es = ES(user = "elastic", password = "elastic")
      @test es.url == "http://elastic:elastic@localhost:9200"
      @test [["a", "b"] |> SourceBlock] |> Query |> JSON.json ==
            """{"_source":["a","b"]}"""
      @test [[SortBody("_score")] |> SortBlock] |> Query |> JSON.json ==
            """{"sort":[{"_score":{"order":"asc"}}]}"""

      @test (TermsBody("name", "foo") |> json) ==
            (TermsBody("name", ["foo"]) |> json) ==
            """{"terms":{"name":["foo"]}}"""


      @test TermsBody("name", "foo") |> MustQueryBlock|>json ==
      """{"bool":{"must":[{"terms":{"name":["foo"]}}]}}"""

      @test [
            SizeBlock(10),
            FromBlock(0),
            RangeBody("correlation", Dict("gte"=>0.5)) |> MustQueryBlock,
            SourceBlock(["id"]),
            SortBlock(["_score"])
      ] |> Query |>json  === "{\"sort\":[\"_score\"],\"size\":10,\"from\":0,\"query\":{\"bool\":{\"must\":[{\"range\":{\"correlation\":{\"gte\":0.5}}}]}},\"_source\":[\"id\"]}"
end
