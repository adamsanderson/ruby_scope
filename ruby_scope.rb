require 'rubygems'
require 'parse_tree'
require 'sexp_path'
require 'unified_ruby'
require 'optparse'

# Example program, this will scan a file for anything
# matching the Sexp passed in.
class RubyScope
  def initialize(args)
    @queries = []
    @verbose = false
    @unifier = Unifier.new
    @numbering = LineNumberingProcessor.new
    
    parse_options(args)
  end
  
  def add_query(pattern)
    # Generate the pattern, we use a little instance_eval trickery here. 
    sexp = SexpPath::SexpQueryBuilder.instance_eval(pattern)
    @queries << sexp
  rescue Exception=>ex
    puts "Invalid Pattern: '#{pattern}'"
    puts "Trace:"
    puts ex
    puts ex.backtrace
    exit 1    
  end
    
  def parse_options(args)    
    opts = OptionParser.new do |opts|    
      opts.banner = "Usage: ruby_scope [options] path"

      opts.separator ""
      opts.separator "Queries:"

      opts.on("-d", "--def NAME", "Find the definition of instance method NAME") do |name|
        add_query("s(:defn, :#{name}, _, _)")
      end
      
      opts.on("-D", "--class-def NAME", "Find the definition of class method NAME") do |name|
        add_query("s(:defs, _, :#{name}, _, _)")
      end
      
      opts.on_tail("-h", "--help", "Show this message") do
        puts opts
        exit
      end  
    end
  
    opts.parse!(args)
    @paths = args
    if @paths.empty?
      puts "A path must be included"
      exit 1
    end
  end
  
  def run
    # For each path the user defined, search for the SexpPath pattern
    @paths.each do |path|  
      # Parse it with ParseTree, and append line numbers
      code = File.read(path)
      lines = nil
      sexp = Sexp.from_array(ParseTree.new(true).parse_tree_for_string(code, path).first)
      sexp = @unifier.process(sexp)
      
      sexp.path = path
      sexp.line = 0
      sexp = @numbering.rewrite(sexp)
      
      found = false
      
      @queries.each do |pattern|
        # Search it with the given pattern, printing any results
        sexp.search_each(pattern) do |match|
          if !found
            puts path
            found = true
          end
          lines ||= code.split("\n")
          line_number = match.sexp.line - 1
          puts "%4i: %s" % [match.sexp.line, lines[line_number]]
        end
      end
    end
  end
end

rs = RubyScope.new(ARGV)
rs.run