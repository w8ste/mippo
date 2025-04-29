using Test

include("../src/Lexer/lexer.jl")
include( "../src/Parser/parser.jl")

function test_lexer(input::String, expected_token_kinds::Vector{TokenKind})
    lexer = init_lexer(input, "<test>", 1, 1, 1)

    for expected_kind in expected_token_kinds
        token = next(lexer)
        @test token.token_kind == expected_kind
    end

    token = next(lexer)
    @test token.token_kind == EOF
end

function test_parser(input::String, expected_nodes::Vector{ExprNode})
    lexer = init_lexer(input, "<test>", 1, 1, 1)

    nodes = start_parse(lexer)

    @test length(nodes) == length(expected_nodes)

    for i in eachindex(nodes)
        @test nodes[i] == expected_nodes[i]
    end
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

@testset "Parser Tests" begin

    @testset "Empty list" begin
        node::Vector{ExprNode} = [ListNode([], Location("<test>",1,1))]
	    test_parser("[]", node)
    end

    @testset "List" begin
        loc = Location("<test>", 1, 3)
        loc2 = Location("<test>", 1, 5)
	    nodes::Vector{ExprNode} = [ListNode([LiteralNode(1.0, loc), LiteralNode(2.0, loc2)], Location("<test>", 1, 1))]

        test_parser("[1 2]", nodes)
    end
end

