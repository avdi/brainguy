require "bundler/gem_tasks"

task :build => :readme

desc "Build the README"
task :readme => "README.md"

file "README.md" => "README.markdown.erb" do
  puts "Generating README.md"
  require "erb"
  template = IO.read("README.markdown.erb")
  IO.write("README.md", ERB.new(template).result)
end
