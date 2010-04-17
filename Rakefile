require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'

begin
  require 'jeweler'
  
  Jeweler::Tasks.new do |s|
    s.name = "ruby_scope"
    s.summary = "Ruby colored binoluars for your code."
    s.description = <<-DESC
      A ruby hacker's search tool.  Quickly interrogate your code, seek out 
      classes, methods, variable assignments, and more.
    DESC
    s.email = "netghost@gmail.com"
    s.homepage = "http://github.com/adamsanderson/ruby_scope"
    s.authors = ["Adam Sanderson"]
    s.files = FileList["[A-Z]*", "{bin,lib,test}/**/*"]
    
    s.add_dependency 'sexp_processor',  '~> 3.0'
    s.add_dependency 'ruby_parser',     '~> 2.0'
    s.add_dependency 'sexp_path',       '>= 0.4'
    
    # Testing
    s.test_files = FileList["test/**/*_test.rb"]
    s.add_development_dependency 'mocha', '>= 0.9.8'
  end

rescue LoadError
  puts "Jeweler not available. Install it for jeweler-related tasks with: sudo gem install jeweler"
end

Rake::RDocTask.new do |t|
  #t.main = "README.rdoc"
  t.rdoc_files.include("lib/**/*.rb")
end

Rake::TestTask.new do |t|
  t.libs << 'lib'
  t.test_files = FileList['test/**/*_test.rb']
  t.verbose = false
end

task :default => :test