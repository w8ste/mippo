include("utils.jl")

@enum TokenKind begin
	LEFT_PAREN
    RIGHT_PAREN
    LEFT_Bracket
    RIGHT_BRACKET
    KEYWORD_DEF
    KEYWORD_FN
    KEYWORD_IF
    OPERATOR
    NUMBER
    BOOLEAN
    IDENTIFIER
    EOF
end

struct Token
    token_kind::TokenKind
    content::Union{Nothing, String, Float64, Int, Bool}
    location::Location
end

struct Lexer
    content::String
    row::Int
    column::Int
    token_buffer_full::Bool
    token_buffer::Token
end
