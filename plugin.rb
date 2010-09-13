Plugin.define do
  name "gdi"
  version "0.0.2"

  object "GDI"
  file "lib", "gdi"

  dependencies  "core",      ">0",
                "HTML View", ">=0.3.2"
end
