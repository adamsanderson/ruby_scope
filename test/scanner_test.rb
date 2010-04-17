require File.dirname(__FILE__) + '/test_helper'

class ScannerTest < Test::Unit::TestCase
  def setup
    @scanner = RubyScope::Scanner.new
    @scanner.cache = {}
  end
  
  def test_scanning_cache_hit_with_no_match
    path = 'cached_sample.rb'
    @scanner.cache[path] = s(:a)
    @scanner.add_query( s(:b) )

    # Should have no hit
    @scanner.expects(:report_match).never   
    # Should not try to read the file since it is cached
    @scanner.expects(:code).never           
    
    @scanner.scan(path)
  end
  
  def test_scanning_cache_hit_with_match
    path = 'cached_sample.rb'
    @scanner.cache[path] = s(:a)
    @scanner.add_query( s(:a) )

    # Should report a match
    @scanner.expects(:report_match)

    @scanner.scan(path)
  end
  
end