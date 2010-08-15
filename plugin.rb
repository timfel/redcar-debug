
Plugin.define do
  name "gdi"
  version "0.0.1"

  object "Redcar::GDI"
  file "lib", "gdi"

  dependencies  "core",      ">0",
                "HTML View", ">=0.3.2",
                "runnables", ">=1.0"
end
