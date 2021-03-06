class RubyScope::CLI
  attr_reader :paths
  attr_reader :cache_path
  attr_reader :scanner
  
  def initialize(args)
    args = args.clone
    @scanner = RubyScope::Scanner.new
    @cache_path = FileUtils.pwd
    
    opts = OptionParser.new do |opts|    
      opts.banner = "Usage: ruby_scope [options] queries path"

      opts.separator ""
      opts.separator "Queries:"

      opts.on("--def NAME", "Find the definition of instance method NAME") do |name|
        @scanner.add_query("s(:defn, #{v name}, _, _)")
      end
      
      opts.on("--class-def NAME", "Find the definition of class method NAME") do |name|
        @scanner.add_query("s(:defs, _, #{v name}, _, _)")
      end
      
      opts.on("--call NAME", "Find method calls of NAME") do |name|
        @scanner.add_query("s(:call, _, #{v name}, _)")
      end
      
      opts.on("--class NAME", "Find definition of NAME") do |name|
        @scanner.add_query("s(:class, #{v name}, _, _)")
      end
      
      opts.on("--variable NAME", "Find references to variable NAME") do |name|
        tag = instance_variable?(name) ? 'ivar' : 'lvar'
        @scanner.add_query("s(:#{tag}, #{v name})")
      end
      
      # Finds block arguments, variable assignments, method arguments (in that order)
      opts.on("--assign NAME", "Find assignments to NAME") do |name|
        tag = instance_variable?(name) ? 'iasgn' : 'lasgn'
        @scanner.add_query("s(:#{tag}, #{v name}) | s(:#{tag}, #{v name}, _) | (t(:args) & SexpPath::Matcher::Block.new{|s| s[1..-1].any?{|a| a == #{v name}}} )")        
      end
      
      opts.on("--any NAME", "Find any reference to NAME (class, variable, number)") do |name|
        @scanner.add_query("include(#{v name})")
      end
      
      opts.on("--custom SEXP_PATH", "Search for a custom SexpPath") do |sexp|
        @scanner.add_query(sexp)
      end
      
      opts.separator ""
      opts.separator "Options:"
      opts.on("-R", "Recursively search folders") do
        @recurse = true
      end
      
      opts.on("--no-cache", "Do not use a cache") do
        @cache_path = nil
      end
      
      opts.on("--cache PATH", "Use the cache at PATH (defaults to current dir)", "Beware, the cache can get rather large") do |path|
        @cache_path = path if path
      end
      
      opts.on("-v", "--verbose", "Verbose output") do
        @scanner.verbose = true
      end
      
      opts.on_tail("-h", "--help", "Show this message") do
        puts opts
        exit
      end  
    end
    opts.parse!(args)
    
    @paths = args
    
    if @paths.empty?
      puts opts
      exit 1
    end
    
    @paths = expand_paths(@paths) if @recurse
    @scanner.cache = RubyScope::SexpCache.new(@cache_path) if @cache_path
  end
  
  def run
    @paths.each do |path|
      @scanner.scan path
    end
  end
  
  protected
  def expand_paths(paths)
    paths.inject([]){|p,v| File.directory?(v) ? p.concat(Dir[File.join(v,'**/*.rb')]) : p << v; p }
  end
  
  # Inserts the appropriate type of value given name.
  # For instance:
  #   v('/cake/') #=> /cake/ # regular expression match
  #   v('apple')  #=> :apple # atom match
  def v(name)
    if name =~ /^\/.+\/$/ # regular expression matching regular expression... WIN!
      "m(#{name})"
    else
      ":#{name}"
    end
  end
  
  def instance_variable?(name)
    name[0..0] == '@'
  end
  
end