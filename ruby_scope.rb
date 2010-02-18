require 'rubygems'
require 'parse_tree'
require 'sexp_path'
require 'unified_ruby'
require 'optparse'

# Example program, this will scan a file for anything
# matching the Sexp passed in.
class RubyScope
  def initialize
    @query = nil
    @verbose = false
    @unifier = Unifier.new
    @numbering = LineNumberingProcessor.new
  end
  
  def add_query(pattern)
    # Generate the pattern, we use a little instance_eval trickery here. 
    sexp = SexpPath::SexpQueryBuilder.instance_eval(pattern)
    if @query 
      @query = @query | sexp
    else
      @query = sexp
    end
    @query
  rescue Exception=>ex
    puts "Invalid Pattern: '#{pattern}'"
    puts "Trace:"
    puts ex
    puts ex.backtrace
    exit 1    
  end
  
  def parse_options!(args)    
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
      
      opts.on("-c", "--call NAME", "Find method calls of NAME") do |name|
        add_query("s(:call, _, :#{name}, _)")
      end
      
      opts.on("-C", "--class NAME", "Find definition of NAME") do |name|
        add_query("s(:class, :#{name}, _, _)")
      end
      
      opts.on("-v", "--variable NAME", "Find references to variable NAME") do |name|
        tag = instance_variable?(name) ? 'ivar' : 'lvar'
        add_query("s(:#{tag}, :#{name})")
      end
      
      opts.on("-a" "--assign NAME", "Find assignments to NAME") do |name|
        tag = instance_variable?(name) ? 'iasgn' : 'lasgn'
        add_query("s(:#{tag}, :#{name}, _) | (t(:args) & SexpPath::Matcher::Block.new{|s| s[1..-1].any?{|a| a == :#{name}}} )")        
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
  
  def run(args)
    parse_options!(args)
    
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
      
      # Search it with the given pattern, printing any results
      sexp.search_each(@query) do |match|
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
  
  private
  def instance_variable?(name)
    name[0..0] == '@'
  end
  
end

rs = RubyScope.new
rs.run(ARGV)