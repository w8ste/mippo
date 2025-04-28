include("../Lexer/lexer.jl")

abstract type ExprNode end

struct LiteralNode <: ExprNode
    value::Union{Int, Float64, String}
    location::Location
end

struct VarNode <: ExprNode
    value::String
    location::Location
end

struct CallNodes <: ExprNode
    func::ExprNode
    args::Vector{ExprNode}
    location::Location
end

struct DefNode <: ExprNode
    name::String
    args::Vector{ExprNode}
    body::ExprNode
    loation::Location
end

struct FnNode
    args::Vector{ExprNode}
    body::ExprNode
    location::Location
end

struct IfNode
    condition::ExprNode
    if_body::ExprNode
    else_body::ExprNode
    location::Location
end
