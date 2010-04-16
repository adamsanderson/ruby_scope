class RubyScope::SexpCache
  VERSION = '0.1'.freeze
  Entry = Struct.new(:last_modified, :sexp)
  
  def initialize(root)
    @root = root
    @cache = load_cache
  end
  
  def [] path
    entry = @cache[path]
    if entry && entry.last_modified == last_modified(path)
      entry.sexp
    else
      @cache.delete path
    end
  end
  
  def []= path, sexp
    @cache[path] = Entry.new(last_modified(path), sexp)
  end
  
  def save
    open(cache_path,'w') do |io|
      io << Marshal.dump(@cache)
    end
  end
  
  def clean
    @cache.keys.each do |path|
      @cache.delete(path) unless File.exist? path
    end
  end
  
  protected
  # TODO: this should iterate up the tree looking for a cache
  def cache_path
    @cache_path ||= File.join(@root, '.ruby_scope.cache')
  end
  
  def last_modified(path)
    File.mtime(path)
  end
  
  def load_cache
    cache = begin
      Marshal.load(File.read(cache_path)) if File.exist?(cache_path)
    rescue Exception=>ex
      STDERR.print("Could not load cache from: #{cache_path}")
      nil
    end
    
    if cache && cache[:version] == VERSION
      cache
    else
      {:version => VERSION}
    end
  end
end