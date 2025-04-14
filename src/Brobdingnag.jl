module Brobdingnag

export Brob

struct Brob{T} <: AbstractFloat
    positive::Bool
    log::T
end

Brob( x::T ) where {T <: Real} = Brob( !(sign(x) < 0), log(abs(x)) )

Brob( x::Brob ) = Brob( x.positive, x.log )

Base.convert( ::Type{Brob}, x::Float64) = Brob( x )

Base.convert( ::Type{Float64}, x::Brob) = (x.positive ? 1 : -1 )*exp( x.log )
Base.convert( ::Type{Float32}, x::Brob) = Float32(convert(Float64, x))

function Base.:+( x::Brob, y::Brob )
    s = x.positive == y.positive ? 1 : -1
    if x.log > y.log
        return Brob( x.positive, x.log + log1p(s * exp(y.log - x.log)) )
    elseif x.log != -Inf || y.log != -Inf
        return Brob( y.positive, y.log + log1p(s * exp(x.log - y.log)) )
    else
        return x
    end
end

Base.:-( x::Brob ) = Brob( !x.positive, x.log )

Base.:-( x::Brob, y::Brob ) = x + Brob(!y.positive, y.log)

Base.:*( x::Brob, y::Brob ) = Brob( x.positive == y.positive, x.log + y.log )

Base.:/( x::Brob, y::Brob ) = Brob( x.positive == y.positive, x.log - y.log )

Base.:^( x::Brob, n::Int ) = Brob( true, n*x.log )

Base.log( x::Brob ) = x.positive ? Brob(x.log) : error( "Negative argument to log" )

Base.exp( x::Brob ) = Brob( true, (-1)^(x.positive+1) * exp(x.log) )

Base.length(::Brob) = 1

Base.iterate( x::Brob ) = (x,nothing)
Base.iterate( x::Brob, ::Nothing ) = nothing

Base.zero( ::Union{Brob,Type{Brob}} ) = Brob( true, -Inf )

Base.ones( ::Type{Brob}, n::Int ) = fill( Brob(true, 0.0), n )

ltdict = [
    true, # -1, false, -1
    true, # -1, false, 0
    true, # -1, false, 1
    true, # -1, true, -1
    true, # -1, true, 0
    true, # -1, true, 1
    false, # 0, false, -1
    false, # 0, false, 0
    true, # 0, false, 1
    true, # 0, true, -1
    false, # 0, true, 0
    false, # 0, true, 1
    false, # 1, false, -1
    false, # 1, false, 0
    false, # 1, false, 1
    false, # 1, true, -1
    false, # 1, true, 0
    false, # 1, true, 1
]

function Base.:<( x::Brob, y::Brob )
    if isnan(x.log) || isnan(y.log)
        return false
    end
    signcmp = cmp( x.positive, y.positive )
    logcmp = cmp( x.log, y.log )
    return ltdict[(signcmp+1)*6 + x.positive*3 +  logcmp + 2]
end

ledict = [
    true, # -1, false, -1
    true, # -1, false, 0
    true, # -1, false, 1
    true, # -1, true, -1
    true, # -1, true, 0
    true, # -1, true, 1
    false, # 0, false, -1
    true, # 0, false, 0
    true, # 0, false, 1
    true, # 0, true, -1
    true, # 0, true, 0
    false, # 0, true, 1
    false, # 1, false, -1
    false, # 1, false, 0
    false, # 1, false, 1
    false, # 1, true, -1
    false, # 1, true, 0
    false, # 1, true, 1
]

function Base.:<=( x::Brob, y::Brob )
    if isnan(x.log) || isnan(y.log)
        return false
    end
    signcmp = cmp( x.positive, y.positive )
    logcmp = cmp( x.log, y.log )
    return ledict[(signcmp+1)*6 + x.positive*3 +  logcmp + 2]
end

Base.promote_rule( ::Type{Brob}, ::Union{Type{Float64},Type{Int},Type{Float32}} ) = Brob

function Base.sqrt( x::Brob )
    @assert( x.positive || x.log != NaN, "Trying to take sqrt of $x" )
    return Brob( true, 0.5*x.log )
end

Base.isnan( x::Brob ) = isnan( x.log )

function Base.write( io::IO, x::Brob )
    write( io, x.positive )
    write( io, x.log )
end

function Base.read( io::IO, ::Type{Brob} )
    positive = read( io, Bool )
    log = read( io, Float64 )
    return Brob( positive, log )
end

end # module
