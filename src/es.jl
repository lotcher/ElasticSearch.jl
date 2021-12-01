struct Error <: Exception
    msg::String
end

struct ES
    url::String
    ES(;
        host::String = "localhost",
        port::Integer = 9200,
        user::String = "",
        password::String = "",
        protocol::String = "http",
    ) = new("$protocol://$user:$password@$host:$port")
    ES(url) = new(url)
end
