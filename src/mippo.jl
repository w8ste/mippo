module mippo

include("Lexer/lexer.jl")

for x in ARGS
    if isfile(x)
        f = open(x, "r")
        content = read(x, String)
        lex = init_lexer(content, x, 1, 1, 1)
        while peek(lex).token_kind != EOF
            println(next(lex))
        end
        close(f)
    end
end

end # module mippo
