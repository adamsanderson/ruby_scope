require 'test/test_helper'

class SexpCacheTest < Test::Unit::TestCase
  def setup
    @path = File.dirname(__FILE__)
    @cache = RubyScope::SexpCache.new(@path)
    @cache.stubs(:last_modified).returns('ok')
  end
  
  def teardown
    File.delete(@cache.cache_path) if File.exists? @cache.cache_path
  end
  
  def test_misses
    assert_equal nil, @cache['missing']
  end
  
  def test_writing_and_reading
    key,value = 'a',s(:code)
    
    @cache[key] = value
    assert_equal value, @cache[key]
  end
  
  def test_expired_reads
    key,value = 'a',s(:code)
    
    @cache[key] = value
    # now invalidate the key
    @cache.stubs(:last_modified).returns('old')
    
    assert_equal nil, @cache[key]
  end
  
  def test_over_writing_and_reading
    key,value1,value2 = 'a',s(:code),s(:new_code)

    @cache[key] = value1
    @cache[key] = value2
    assert_equal value2, @cache[key]
  end  
end