export clplatec

function clplatec(;
  n::Int = default_nvar,
  type::Val{T} = Val(Float64),
  wght = -0.1,
  r = 0.99,
  l = 0.01,
  kwargs...,
) where {T}
  p = floor(Int, sqrt(n))
  p * p != n && @warn("clplatec: number of variables adjusted from $n down to $(p*p)")
  n = p * p

  hp2 = T(1 / 2) * p^2
  wr = T(wght * r)
  wl = T(wght * l)
  function f(x)
    return wr * x[p + (p - 1) * p] +
           wl * x[p] +
           sum(
             sum(
               hp2 * (x[i + (j - 1) * p] - x[i + (j - 2) * p])^2 +
               (x[i + (j - 1) * p] - x[i + (j - 2) * p])^4 for j = 2:p
             ) for i = 2:p
           ) +
           sum(
             sum(
               T(1 / 2) * (x[i + (j - 1) * p] - x[i - 1 + (j - 1) * p])^2 +
               (x[i + (j - 1) * p] - x[i - 1 + (j - 1) * p])^4 for j = 2:p
             ) for i = 3:p
           ) +
           sum(T(1 / 2) * (x[2 + (j - 1) * p])^2 + (x[2 + (j - 1) * p])^4 for j = 2:p)
  end
  x0 = zeros(T, n)
  return ADNLPModels.ADNLPModel(f, x0, name = "clplatec"; kwargs...)
end
