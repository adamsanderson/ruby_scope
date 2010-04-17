require 'dbm'
class RubyScope::SexpCache
  DB = DBM
  CacheEntry = Struct.new(:last_modified, :sexp)
  
  def initialize(root)
    @root = root
  end
  
  def [] path
    with_cache do |cache|
      entry = cache[path]
      entry = Marshal.load(entry) if entry
      
      if entry && entry.last_modified == last_modified(path)
        entry.sexp
      else
        cache.delete path
        nil
      end
    end
  end
  
  def []= path,value
    with_cache do |cache|
      entry = CacheEntry.new(last_modified(path), value)
      cache[path] = Marshal.dump(entry)
    end
  end
  
  def cache_path
    @cache_path ||= File.join(@root,'.ruby_scope.cache')
  end
  
  protected
  def with_cache
    DB.open(cache_path, 0666) do |cache|
      yield cache
    end
  end
  
  def last_modified(path)
    File.mtime(path)
  end
end