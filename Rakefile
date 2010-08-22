
def missing(tool)
  "You need #{tool} to compile this plugin"
end

task :compile do
  p "git submodule init && git submodule sync && git submodule update"
  system("git submodule init && git submodule sync && git submodule update")
  system("ruby -Ivendor/haml/lib vendor/haml/bin/sass views/index.sass views/index.css")
  fail missing("coffee-script") unless system("coffee -c views/index.coffee")
end

task :default => :compile

