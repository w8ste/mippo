include("utils.jl")
include("lexer_error.jl")

@enum TokenKind begin
	LEFT_PAREN
    RIGHT_PAREN
    LEFT_BRACKET
    RIGHT_BRACKET
    KEYWORD_DEF
    KEYWORD_FN
    KEYWORD_IF
    KEYWORD_BOOL
    OPERATOR
    TOKEN_NUMBER
    TOKEN_STRING
    IDENTIFIER
    TOKEN_PLUS
    TOKEN_MINUS
    TOKEN_MULTIPY
    TOKEN_DIVIDE
    TOKEN_EQ
    TOKEN_LET
    TOKEN_GET
    EOF
    EmptyToken
end

struct Token
    token_kind::TokenKind
    content::Union{Nothing, String, Float64, Int, Bool}
    location::Location
end

mutable struct Lexer
    content::String
    file_path::String
    pos::Int
    row::Int
    column::Int
    token_buffer_full::Bool
    token_buffer::Token
end

function is_whitespace(c::Char)
    c == ' ' || c == '\n' || c == '\t'
end

function is_digit(c::Char)
    '0' <= c <= '9'
end

function is_letter(c::Char)
    ('a' <= c <= 'z') || ('A' <= c <= 'Z') || c == '_'
end

function skip_whitespace(lexer::Lexer)
    while lexer.pos <= length(lexer.content) && is_whitespace(lexer.content[lexer.pos])
        if lexer.content[lexer.pos] == '\n'
            lexer.pos += 1
            lexer.column = 1
            lexer.row += 1
        elseif lexer.content[lexer.pos] == '\t'
            lexer.pos += 4
            lexer.column += 4
        else
            lexer.pos += 1
            lexer.column += 1
        end
    end
end


function tokenize_until_char(lexer::Lexer, c::Char, loc::Location)::Int64

    lexer.column += 1
    lexer.pos += 1
    while lexer.pos <= length(lexer.content) && lexer.content[lexer.pos] != c
        lexer.column += 1
        lexer.pos += 1        
    end
    loc.column = lexer.column
    e::Int64 = lexer.pos

    
    if lexer.pos > length(lexer.content)
        throw(LexerErr("Undetermined Non-Terminal. Expected $(c)", loc))
    elseif lexer.content[lexer.pos] == c
        lexer.column += 1
        lexer.pos += 1
    end

    return e
end

function extract_identifier_or_keyword(lexer::Lexer)::Token
    buffer = ""
    start = lexer.column

    while lexer.pos <= length(lexer.content) && is_letter(lexer.content[lexer.pos])
        buffer *= lexer.content[lexer.pos]
        lexer.pos += 1
        lexer.column += 1
    end

    loc::Location = make_location(lexer.file_path, lexer.row, start)
    
    if buffer == "if"
        return Token(KEYWORD_IF, buffer, loc)
    elseif buffer == "def"
        return Token(KEYWORD_DEF, buffer, loc)
    elseif buffer == "fn"
        return Token(KEYWORD_FN, buffer, loc)
    elseif buffer == "true" || buffer == "false"
        return Token(KEYWORD_BOOL, buffer, loc)
    else
        return Token(IDENTIFIER, buffer, loc)
    end
end

function tokenize_digits(lexer::Lexer, buffer::String)::String
    while lexer.pos <= length(lexer.content) && is_digit(lexer.content[lexer.pos])
        buffer *= lexer.content[lexer.pos]
        lexer.pos += 1
        lexer.column += 1
    end

    return buffer
end

function extract_number(lexer::Lexer)::Token
    buffer = ""

    buffer *= tokenize_digits(lexer, buffer)
    
    if lexer.content[lexer.pos] == '.'
        buffer *= '.'
        lexer.pos += 1
        lexer.column += 1

        buffer = tokenize_digits(lexer, buffer)
    end

    loc::Location = make_location(lexer.file_path, lexer.row, lexer.column)

    if buffer == ""
        throw(LexerErr("Something went wrong whils trying to parse a number!", loc))
    end

    
    value = parse(Float64, buffer)
    
    return Token(TOKEN_NUMBER, value, loc)
end

function extract_token(lexer::Lexer)::Token
    skip_whitespace(lexer)
    
    loc::Location = make_location(lexer.file_path, lexer.row, lexer.column)
    if lexer.pos > length(lexer.content)
        return Token(EOF, nothing, loc)
    end

    c = lexer.content[lexer.pos]
    loc = make_location(lexer.file_path, lexer.row, lexer.column)

    if c == '('
        lexer.token_buffer = Token(LEFT_PAREN, "(", loc)
        advance(lexer)
    elseif c == ')'
        lexer.token_buffer = Token(RIGHT_PAREN, ")", loc)
        advance(lexer)        
    elseif c == '['
        lexer.token_buffer = Token(LEFT_BRACKET, "[", loc)
        advance(lexer)
    elseif c == ']'
        lexer.token_buffer = Token(RIGHT_BRACKET, "]", loc)
        advance(lexer)
    elseif c == '+'
        lexer.token_buffer = Token(TOKEN_PLUS, "+", loc)
        advance(lexer)
    elseif c == '-'
        lexer.token_buffer = Token(TOKEN_MINUS, "-", loc)
        advance(lexer)
    elseif c == '*'
        lexer.token_buffer = Token(TOKEN_MULTIPY, "*", loc)
        advance(lexer)
    elseif c ==  '/'
        lexer.token_buffer = Token(TOKEN_DIVIDE, "/", loc)
        advance(lexer)
    elseif c == '='
        if lexer.pos + 1 > length(lexer.content) || lexer.content[lexer.pos + 1] != '='
            throw(LexerErr("Unexprected Token, Expected \"=\"", loc))
        end
        lexer.token_buffer = Token(TOKEN_EQ, "==", loc)
        advance(lexer, 2)
    elseif c == '<'
        if lexer.pos + 1 > length(lexer.content) || lexer.content[lexer.pos + 1] != '='
            throw(LexerErr("Unexprected Token, Expected \"=\"", loc))
        end
        lexer.token_buffer = Token(TOKEN_LET, "<=", loc)
        advance(lexer, 2)
    elseif c == '>'
        if lexer.pos + 1 > length(lexer.content) || lexer.content[lexer.pos + 1] != '='
            throw(LexerErr("Unexprected Token, Expected \"=\"", loc))
        end
        lexer.token_buffer = Token(TOKEN_GET, ">=", loc)
        advance(lexer, 2)
    elseif is_letter(c)
        lexer.token_buffer = extract_identifier_or_keyword(lexer)
    elseif is_digit(c)
        lexer.token_buffer = extract_number(lexer)
    elseif c == '"'
        start = lexer.pos
        e = tokenize_until_char(lexer, '"', loc)
        lexer.token_buffer = Token(TOKEN_STRING, lexer.content[start:e], loc)
    elseif c == '#'
        while lexer.pos <= length(lexer.content) && lexer.content[lexer.pos] != '\n'
            advance(lexer)
        end
        return extract_token(lexer)
    else
        throw(LexerErr("Expected a token, but got $(lexer.content[lexer.pos])", loc))
    end

    return lexer.token_buffer
          
end

function next(lexer::Lexer)::Token
	if lexer.token_buffer_full
        lexer.token_buffer_full = false
        return lexer.token_buffer
    end
    
    return extract_token(lexer)
end

function peek(lexer::Lexer)

    if lexer.token_buffer_full
        return lexer.token_buffer
    else
        lexer.token_buffer_full = true
    end
    
    return extract_token(lexer)
end

function init_lexer(content::String, file_path::String, pos::Int, row::Int, column::Int,)
    Lexer(content, file_path, pos, row, column, false, Token(EmptyToken, "", make_location(file_path, row, pos)))
end

function advance(lexer::Lexer)
    lexer.column += 1
    lexer.pos += 1
end

function advance(lexer::Lexer, n::Int)
    for _ in 1:n
        lexer.column += 1
        lexer.pos += 1
    end
end
