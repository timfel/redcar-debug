desc "Compile resources"
task :compile => [:gems] do
  p "git submodule init && git submodule sync && git submodule update"
  system("git submodule init && git submodule sync && git submodule update")
  system("ruby -Ivendor/haml/lib vendor/haml/bin/sass views/index.sass views/index.css")
  fail missing("coffee-script") unless system("coffee -c views/index.coffee")
end

desc "Run specs"
task :spec do
  jvm_opt = "-J-XstartOnFirstThread" if RbConfig::CONFIG['host_os'] == 'darwin'
  system("jruby #{jvm_opt} -S spec spec/ && echo 'done'")
end

desc "Install required gems"
task :gems do
  begin
    require 'bundler'
  rescue LoadError
    system("gem install bundler")
    require 'bundler'
  end
  system("bundle install")
end

task :default => :compile

