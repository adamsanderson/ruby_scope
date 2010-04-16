class RubyScope::CLI
  def initialize(args)
    args = args.clone
    @scanner = RubyScope::Scanner.new
    
    opts = OptionParser.new do |opts|    
      opts.banner = "Usage: ruby_scope [options] path"

      opts.separator ""
      opts.separator "Queries:"

      opts.on("-d", "--def NAME", "Find the definition of instance method NAME") do |name|
        @scanner.add_query("s(:defn, :#{name}, _, _)")
      end
      
      opts.on("-D", "--class-def NAME", "Find the definition of class method NAME") do |name|
        @scanner.add_query("s(:defs, _, :#{name}, _, _)")
      end
      
      opts.on("-c", "--call NAME", "Find method calls of NAME") do |name|
        @scanner.add_query("s(:call, _, :#{name}, _)")
      end
      
      opts.on("-C", "--class NAME", "Find definition of NAME") do |name|
        @scanner.add_query("s(:class, :#{name}, _, _)")
      end
      
      opts.on("-v", "--variable NAME", "Find references to variable NAME") do |name|
        tag = instance_variable?(name) ? 'ivar' : 'lvar'
        @scanner.add_query("s(:#{tag}, :#{name})")
      end
      
      # Finds block arguments, variable assignments, method arguments (in that order)
      opts.on("-a", "--assign NAME", "Find assignments to NAME") do |name|
        tag = instance_variable?(name) ? 'iasgn' : 'lasgn'
        @scanner.add_query("s(:#{tag}, :#{name}) | s(:#{tag}, :#{name}, _) | (t(:args) & SexpPath::Matcher::Block.new{|s| s[1..-1].any?{|a| a == :#{name}}} )")        
      end
      
      opts.on("-R", "Recursively search folders") do
        @recurse = true
      end
      
      opts.on("--verbose", "Verbose output") do |name|
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
  
  def instance_variable?(name)
    name[0..0] == '@'
  end
  
end