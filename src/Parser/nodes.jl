include("../Lexer/lexer.jl")

abstract type ExprNode end

struct EOFNode <: ExprNode
    location::Location
end

struct EmptyNode <: ExprNode
    location::Location
end

struct LiteralNode <: ExprNode
    value::Union{Int, Float64, String}
    location::Location
end

struct VarNode <: ExprNode
    value::String
    location::Location
end

struct CallNode <: ExprNode
    func::ExprNode
    args::Vector{ExprNode}
    location::Location
end

struct DefNode <: ExprNode
    name::String
    args::Vector{IDENTIFIER}
    body::Vector{ExprNode}
    loation::Location
end

struct FnNode <: ExprNode
    args::Vector{Token}
    body::ExprNode
    location::Location
end

struct IfNode <: ExprNode
    condition::ExprNode
    if_body::ExprNode
    else_body::ExprNode
    location::Location
end

struct ListNode <: ExprNode
    nodes::Vector{ExprNode}
    location::Location
end

Base.:(==)(a::ListNode, b::ListNode) = begin
    a.location == b.location && a.nodes == b.nodes
end

Base.:(==)(a::LiteralNode, b::LiteralNode) = a.location == b.location && a.value == b.value
