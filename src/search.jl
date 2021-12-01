using JSON, HTTP
include("es.jl")

const BlockNames = Dict(
    :MustQueryBlock => "query",
    :HighlightBlock => "highlight",
    :SourceBlock => "_source",
    :FromBlock => "from",
    :SizeBlock => "size",
)

abstract type FilterBody end

struct RangeBody <: FilterBody
    field::String
    range::Dict{String,Any}
end
JSON.lower(rb::RangeBody) = Dict("range" => Dict(rb.field => rb.range))


struct MultiMatchBody <: FilterBody
    fields::Vector{String}
    query::String
end
JSON.lower(mm::MultiMatchBody) =
    Dict("multi_match" => Dict("fields" => mm.fields, "query" => mm.query))


abstract type Block end

struct MustQueryBlock <: Block
    bodys::Vector{FilterBody}
end
JSON.lower(mq::MustQueryBlock) = Dict("bool" => Dict("must" => mq.bodys))

struct HighlightBlock <: Block
    fields::Vector{String}
end
JSON.lower(hb::HighlightBlock) =
    Dict("fields" => Dict(field => Dict() for field in hb.fields))

struct SourceBlock <: Block
    fields::Vector{String}
end
JSON.lower(sb::SourceBlock) = sb.fields

struct FromBlock <: Block
    from::Integer
end
JSON.lower(fb::FromBlock) = fb.from

struct SizeBlock <: Block
    size::Integer
end
JSON.lower(sb::SizeBlock) = sb.size


struct Query
    blocks::Vector{Block}
end
JSON.lower(q::Query) = begin
    Dict(
        get(BlockNames, block |> typeof |> nameof |> Symbol, "error") =>
            block for block in q.blocks
    )
end

function search(es::ES, index::String, query::String)
    res = HTTP.get(
        "$(es.url)/$index/_search",
        headers = Dict("content-type" => "application/json"),
        body = query,
    )
    String(res.body) |> JSON.parse
end

function search(es::ES, index::String, query::Union{Query,Dict})
    search(es, index, JSON.json(query))
end

function search(query_func::Function; es::ES, index::String)
    search(es, index, query_func())
end
