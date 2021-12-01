using ElasticSearch
using Test, JSON

@testset "ElasticSearch.jl" begin
    es = ES(user = "elastic", password = "elastic")
    @test es.url == "http://elastic:elastic@localhost:9200"
    @test [["a", "b"] |> SourceBlock] |> Query |> JSON.json == """{"_source":["a","b"]}"""
end
