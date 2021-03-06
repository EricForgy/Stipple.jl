module Elements

using Revise
import Genie
using Stipple

import Genie.Renderer.Html: HTMLString, normal_element

export root, elem, @iif, @elsiif, @els, @text, @bind, @data

#===#

function root(app::M)::String where {M<:ReactiveModel}
  Genie.Generator.validname(typeof(app) |> string)
end

function root(app::Type{M})::String where {M<:ReactiveModel}
  Genie.Generator.validname(app |> string)
end

function elem(app::M)::String where {M<:ReactiveModel}
  "#$(root(app))"
end

#===#

function vue_integration(model::M; vue_app_name::String, endpoint::String, channel::String)::String where {M<:ReactiveModel}
  vue_app = replace(Genie.Renderer.Json.JSONParser.json(model |> Stipple.render), "\"{" => " {")
  vue_app = replace(vue_app, "}\"" => "} ")

  output = "var $vue_app_name = new Vue($vue_app);\n\n"

  for field in fieldnames(typeof(model))
    output *= Stipple.watch(vue_app_name, getfield(model, field), field, channel, model)
  end

  output *= "\n\nwindow.parse_payload = function(payload){ window.$(vue_app_name)[payload.key] = payload.value; };"
end

#===#

macro iif(expr)
  "v-if='$(startswith(string(expr), ":") ? string(expr)[2:end] : expr)'"
end

macro elsiif(expr)
  "v-else-if='$(startswith(string(expr), ":") ? string(expr)[2:end] : expr)'"
end

macro els(expr)
  "v-else='$(startswith(string(expr), ":") ? string(expr)[2:end] : expr)'"
end

macro text(expr)
  directive = occursin(" | ", string(expr)) ? ":text-content.prop" : "v-text"
  "$(directive)='$(startswith(string(expr), ":") ? string(expr)[2:end] : expr)'"
end

macro bind(expr)
  "v-model='$(startswith(string(expr), ":") ? string(expr)[2:end] : expr)'"
end

macro data(expr)
  :(Symbol($expr))
end

#===#

include(joinpath("elements", "stylesheet.jl"))

end