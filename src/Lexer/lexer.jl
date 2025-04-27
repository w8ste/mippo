include("utils.jl")
include("lexer_error.jl")

@enum TokenKind begin
	LEFT_PAREN
    RIGHT_PAREN
    LEFT_Bracket
    RIGHT_BRACKET
    KEYWORD_DEF
    KEYWORD_FN
    KEYWORD_IF
    KEYWORD_BOOL
    OPERATOR
    TOKEN_NUMBER
    IDENTIFIER
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

function extract_identifier_or_keyword(lexer::Lexer)
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

function tokenize_digits(lexer::Lexer, buffer::String)
    while lexer.pos < length(lexer.content) && is_digit(lexer.content[lexer.pos])
        buffer *= lexer.content[lexer.pos]
        lexer.pos += 1
        lexer.column += 1
    end
    return buffer
end

function extract_number(lexer::Lexer)
    buffer = ""

    buffer *= tokenize_digits(lexer, buffer)
    
    if lexer.content[lexer.pos] == '.'
        buffer *= '.'
        lexer.pos += 1
        lexer.column += 1

        buffer *= tokenize_digits(lexer, buffer)
    end

    loc::Location = make_location(lexer.file_path, lexer.row, lexer.column)

    if buffer == ""
        throw(LexerErr("Something went wrong whils trying to parse a number!", make_location(lexer.file_path, lexer.row, lexer.column)))
    end
    
    value = parse(Float64, buffer)
    
    return Token(TOKEN_NUMBER, value, loc)
end

function extract_token(lexer::Lexer)
    skip_whitespace(lexer)
    
    if lexer.pos > length(lexer.content)
        return Token(EOF, nothing, make_location(lexer.file_path, lexer.row, lexer.pos))
    end

    c = lexer.content[lexer.pos]
   
    if c == '('
        lexer.token_buffer = Token(LEFT_PAREN, "(", make_location(lexer.file_path, lexer.row, lexer.column))
        lexer.pos += 1
        lexer.column += 1
    elseif c == ')'
        lexer.token_buffer = Token(RIGHT_PAREN, ")", make_location(lexer.file_path, lexer.row, lexer.column))
        lexer.pos += 1
        lexer.column += 1
    elseif c == '['
        lexer.token_buffer = Token(LEFT_Bracket, "[", make_location(lexer.file_path, lexer.row, lexer.column))
        lexer.pos += 1
        lexer.column += 1
    elseif c == ']'
        lexer.pos += 1
        lexer.column += 1
        lexer.token_buffer = Token(RIGHT_BRACKET, "]", make_location(lexer.file_path, lexer.row, lexer.column))
    elseif is_letter(c)
        lexer.token_buffer = extract_identifier_or_keyword(lexer)
    elseif is_digit(c)
        lexer.token_buffer = extract_number(lexer)
    else
        throw(LexerErr("Expected a token, but got $(lexer.content[lexer.pos])", make_location(lexer.file_path, lexer.row, lexer.column)))
    end

    return lexer.token_buffer
          
end

function next(lexer::Lexer)
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
