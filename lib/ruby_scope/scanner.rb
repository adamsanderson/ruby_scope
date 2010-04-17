class RubyScope::Scanner
  attr_accessor :verbose
  attr_accessor :cache
  
  def initialize
    @query = nil
    @verbose = false
  end
  
  def add_query(pattern)
    # Generate the pattern, we use a little instance_eval trickery here. 
    sexp = case pattern
      when String then SexpPath::SexpQueryBuilder.instance_eval(pattern)
      when Sexp   then pattern
      else raise ArgumentError, "Expected a String or Sexp"
    end
    
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
  
  def query
    @query.clone if @query
  end
  
  def scan(path)
    @path = path
    begin
      report_file path
      
      # Reset our cached code and split lines
      @code,@lines = nil,nil
            
      # Load the code and parse it with RubyParser
      # If we're caching pull from the cache, otherwise parse the code
      sexp = @cache[path] if @cache
      if !sexp
        sexp = RubyParser.new.parse(code, @path)
        @cache[path] = sexp if @cache
      end
 
      if sexp
        # Search it with the given pattern, printing any results
        sexp.search_each(@query) do |matching_sexp|
          report_match matching_sexp
        end 
      end
    rescue StandardError => ex
      report_exception ex
    end
  end
  
  protected
  def report_file(path)
    puts @path if @verbose
  end
  
  def report_match(match)
    if !@lines
      puts @path unless @verbose
      @lines = code.split("\n")
    end
    line_number = match.sexp.line - 1
    puts "%4i: %s" % [match.sexp.line, @lines[line_number].strip]
  end
  
  def report_exception(ex)
    debug "Problem processing '#{@path}'"
    debug ex.message.strip
    debug ex.backtrace.map{|line| "  #{line}"}.join("\n")
  end
  
  def code
    @code ||= File.read(@path)
  end
  
  def debug(msg)
    STDERR.print(msg.to_s.chomp + "\n")
  end
  
end