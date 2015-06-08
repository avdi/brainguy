require "bundler/gem_tasks"
require "yard"

task :build => :readme

desc "Build the README"
task :readme => "README.markdown"

file "README.markdown" => "README.markdown.erb" do
  puts "Generating README.markdown"
  require "erb"
  template = IO.read("README.markdown.erb")
  IO.write("README.markdown", ERB.new(template).result)
end

YARD::Rake::YardocTask.new do |t|
  # t.files   = ['lib/**/*.rb', OTHER_PATHS]   # optional
  # t.options = ['--any', '--extra', '--opts'] # optional
  # t.stats_options = ['--list-undoc']         # optional
end
task :yard => :readme
