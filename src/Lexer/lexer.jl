include("utils.jl")

@enum TokenKind begin
	$0
end

struct Token
    content::String
    token_kind::TokenKind
    location::Location
end

struct Lexer
    content::String
    row::Int
    column::Int
    token_buffer_full::Bool
    token_buffer::Token
end
