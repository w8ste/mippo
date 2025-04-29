using Test

include("../src/Lexer/lexer.jl")

function test_lexer(input::String, expected_token_kinds::Vector{TokenKind})
    lexer = init_lexer(input, "<test>", 1, 1, 1)

    for expected_kind in expected_token_kinds
        token = next(lexer)
        @test token.token_kind == expected_kind
    end

    token = next(lexer)
    @test token.token_kind == EOF
end

@testset "Lexer Tests" begin

    @testset "Empty file" begin
        test_lexer("", [EOF])
    end

    @testset "Whitespace only" begin
        test_lexer("   \n\t ", [EOF])
    end

    @testset "Single identifier" begin
        test_lexer("hello", [IDENTIFIER])
    end

    @testset "Simple function call" begin
        test_lexer("(greet \"hippo\")", [LEFT_PAREN, IDENTIFIER, TOKEN_STRING, RIGHT_PAREN])
    end

    @testset "List literal" begin
        test_lexer("[1 2 3]", [LEFT_BRACKET, TOKEN_NUMBER, TOKEN_NUMBER, TOKEN_NUMBER, RIGHT_BRACKET])
    end

end
