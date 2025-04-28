include("nodes.jl")
include("parser_error.jl")


function parseExpr(lexer::Lexer)::ExprNode
    
end

function start_parse(lexer::Lexer)::ExprNode

    nodes = ExprNode[]
    
    while peek(lexer).token_kind != EOF
        push!(nodes, parse_expression(lexer))
    end
end

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

function parse_in_parens(lexer::Lexer)::ExprNode

end

function parse_list(lexer::Lexer)::ListNode

    nodes = ExprNode[]


    start::Location = peek(lexer).location


    
    while true
        next(lexer)
        if peek(lexer) == EOF
            throw(ParseError("Expected closing ], got EOL", start))
        elseif peek(lexer).token_kind == RIGHT_BRACKET
            break
        end

        

        push!(nodes, parse_expression(lexer))

        if EOF in nodes
            break

       
    end
        

    end


    return ListNode(nodes, start)
end

function expect(lexer::Lexer, expected::TokenKind)::Token
    v = next(lexer)

    if v.token_kind != expected
        throw(ParseError("Expected $(expected), but got $(v)", v.location))
    end
    return v
end

 
