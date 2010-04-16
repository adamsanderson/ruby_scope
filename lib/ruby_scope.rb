require 'rubygems'
require 'ruby_parser'
require 'sexp_path'
require 'unified_ruby'
require 'optparse'

# RubyScope is a command line tool designed to help you scan ruby code lexically.
# See the README for more information.
module RubyScope
end

# Load RubyScope
root = File.dirname(__FILE__)+'/ruby_scope/'
%w[
  scanner
  cli
].each do |file|
  require root+file
end