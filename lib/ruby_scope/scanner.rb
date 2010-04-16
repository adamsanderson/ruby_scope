class RubyScope::Scanner
  attr_accessor :verbose
  
  def initialize
    @query = nil
    @verbose = false
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
  
  def scan(path)
    @path = path
    begin
      report_file path
      
      # Load the code and parse it with RubyParser
      @code = File.read(path)
      @lines = nil

      if sexp = RubyParser.new.parse(@code, @path)
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
      @lines = @code.split("\n")
    end
    line_number = match.sexp.line - 1
    puts "%4i: %s" % [match.sexp.line, @lines[line_number].strip]
  end
  
  def report_exception(ex)
    debug "Problem processing '#{@path}'"
    debug ex.message.strip
    debug ex.backtrace.map{|line| "  #{line}"}.join("\n")
  end
  
  def debug(msg)
    STDERR.print(msg.to_s.chomp + "\n")
  end
  
end