module ElasticSearch

include("search.jl")

export ES, Query, search, test
export RangeBody, MultiMatchBody
export MustQueryBlock, HighlightBlock, SourceBlock, FromBlock, SizeBlock, Block



end
