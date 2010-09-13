if ENV["REDCAR_HOME"]
  $:.push File.expand_path("lib", ENV["REDCAR_HOME"])
else
  $:.push File.expand_path('../../../../lib', __FILE__)
end

begin
  require 'redcar'
  Redcar.environment = :test
  Redcar.load_unthreaded
rescue LoadError
  "Couldn't load redcar. Please set your REDCAR_HOME environment variable to point to your Redcar source tree"
  exit 1
end

require File.expand_path("../../lib/gdi", __FILE__)
