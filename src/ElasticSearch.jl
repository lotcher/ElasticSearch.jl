module ElasticSearch

include("search.jl")

export ES, Query, search, test
export RangeBody, MultiMatchBody, SortBody, TermsBody
export MustQueryBlock, HighlightBlock, SourceBlock, FromBlock, SizeBlock,
        SortBlock, Block



end
