using JSON, HTTP
include("es.jl")

const BlockNames = Dict(
    :MustQueryBlock => "query",
    :HighlightBlock => "highlight",
    :SourceBlock => "_source",
    :FromBlock => "from",
    :SizeBlock => "size",
    :SortBlock => "sort"
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

struct TermsBody <: FilterBody
    field::String
    values::Vector
    TermsBody(field, values::Vector) = new(field, values)
    TermsBody(field, value::Union{String, Number}) = new(field, [value])
end
JSON.lower(tb::TermsBody) = Dict("terms"=>Dict(tb.field=>tb.values))

abstract type Block end

struct MustQueryBlock <: Block
    bodys::Vector{FilterBody}
    MustQueryBlock(bodys::Vector{FilterBody}) = new(bodys)
    MustQueryBlock(body::FilterBody) = new([body])
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


struct SortBody
    field::String
    order::String
    SortBody(field, ascending::Bool = true) =
        new(field, ascending ? "asc" : "desc")
end
JSON.lower(sb::SortBody) = Dict(sb.field => Dict("order" => sb.order))
struct SortBlock <: Block
    bodys::Vector{Union{SortBody,String}}
end
JSON.lower(sb::SortBlock) = sb.bodys


struct Query
    blocks::Vector{Block}
    Query(blocks::Vector{Block}) = new(blocks)
    Query(block::Block) = new([blocks])
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
