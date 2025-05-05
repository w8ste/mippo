include("../Lexer/lexer.jl")

"""
    parse_args(lexer) -> Vector{Token}

    This functions provides the utility of parsing any type of arguments. Additionally it will
    parse the closing RPAREN.

    # Expection
    - ParseError: In case of an unexpected EOF an error will be thrown.
"""
function parse_args(lexer::Lexer)::Vector{Token}
    expect(lexer, LEFT_PAREN)

    args::Vector{Token} = Token[]

    while peek(lexer).token_kind != RIGHT_PAREN
        println(peek(lexer))

        if peek(lexer) == EOF
            throw(ParseError("Unexpected EOF", peek(lexer).location))
        end

        push!(args, expect(lexer, IDENTIFIER))
    end

    expect(lexer, RIGHT_PAREN)

    return args
end

function parse_function_body(lexer::Lexer)::Vector{ExprNode}
    body::Vector{ExprNode} = ExprNode[]
    
    while(peek(lexer).token_kind != RIGHT_BRACKET)
        if peek(lexer).token_kind == EOF
           throw(ParseError("Expected ')', but got EOF", peek(lexer).location)) 
        end
        push!(body, parse_expression(lexer))
    end

    return body

end


function expect(lexer::Lexer, expected::TokenKind)::Token
    v = next(lexer)

    if v.token_kind != expected
        throw(ParseError("Expected $(expected), but got $(v)", v.location))
    end
    return v
end

 
