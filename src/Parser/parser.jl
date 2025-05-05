include("nodes.jl")
include("parser_error.jl")
include("parser_utils.jl")
"""
    start_parse(lexer) -> Vector{ExpNodes}

    This function is the enty point to parsing the content contained within the content field of
    of the provided lexer
"""
function start_parse(lexer::Lexer)::Vector{ExprNode}

    nodes = ExprNode[]
    
    while peek(lexer).token_kind != EOF
        push!(nodes, parse_expression(lexer))
    end

    return nodes
end

"""
    parse_expression(lexer) -> ExprNode

    This function will parse an expression based on how it is defined within the specification
    document.
"""
function parse_expression(lexer::Lexer)::ExprNode
    tok = peek(lexer)

    if tok.token_kind == EOF
        return EOFNode(tok.location)
    elseif tok.token_kind == LEFT_BRACKET
        return parse_list(lexer)
    elseif tok.token_kind == TOKEN_NUMBER || tok.token_kind == KEYWORD_BOOL || tok.token_kind == TOKEN_STRING # parse literal
        return LiteralNode(tok.content, tok.location)
    elseif tok.token_kind == LEFT_PAREN # parse def, fn, call, if
        return parse_in_parens(lexer)
    else
        throw(LexerErr("Unexpected Token, got $(tok)", tok.location))
    end
end

"""
    parse_in_parens(lexer) -> ExprNode

    This function is a helper function for parse_expression. It handles every type of expression
    that is supposed to start with the LPAREN token. This includes function definitions, function
    calls, lambda expressions etc.    
"""
function parse_in_parens(lexer::Lexer)::ExprNode

    start::Location = peek(lexer).location
    expect(lexer, LEFT_PAREN)
    
    tok::Token = peek(lexer)

    if tok.token_kind == KEYWORD_DEF
        return parse_function_definition(lexer, start)
    elseif tok.token_kind == KEYWORD_FN
        return parse_anonymous_function(lexer, start)
    elseif tok.token_kind == IDENTIFIER
        return parse_call(lexer, start)
    end
    
end

"""
    parse_call(lexer) -> CallNode

    This function is a helper function for the parse_in_parens function.
    It handles function calls.
"""
function parse_call(lexer::Lexer, start::Location)::CallNode
    func::ExprNode = parse_expression(lexer)

    args::Vector{Token} = parse_args(lexer)

    return CallNode(func, args, start)
end

"""
    parse_function_definition(lexer, start) -> DefNode

    This function is a helper function for the parse_in_parens function.
    It handles function definitions.
"""
function parse_function_definition(lexer::Lexer, start::Location)::DefNode
    expect(lexer, KEYWORD_DEF)

    token_name = expect(lexer, IDENTIFIER).content
    args::Vector{Token} = parse_args(lexer)
    body::Vector{ExprNode} = parse_function_body(lexer)

    return DefNode(token_name, args, body, start)
end

"""
    parse_anonymous_function(lexer, start) -> FnNode

    This function is a helper function for the parse_in_parents function.
    It handles anonymous function definitions/lambdas.
"""
function parse_anonymous_function(lexer::Lexer, start::Location)::FnNode
    expect(lexer, KEYWORD_FN)

    args::Vector{Token} = parse_args(lexer)
    body::Vector{ExprNode} = parse_function_body(lexer)

    return FnNode(args, body, start)
end

function parse_list(lexer::Lexer)::ListNode

    nodes = ExprNode[]
    start::Location = peek(lexer).location
    expect(lexer, LEFT_BRACKET)
    
    while peek(lexer).token_kind != RIGHT_BRACKET
        if peek(lexer) == EOF
            throw(ParseError("Expected closing ], got EOL", start))
        end

        push!(nodes, parse_expression(lexer))
        next(lexer)
    end

    expect(lexer, RIGHT_BRACKET)

    return ListNode(nodes, start)
end
