require File.dirname(__FILE__) + '/test_helper'

class CLITest < Test::Unit::TestCase  
  def test_configuring_scanner
    query = scanner_with('--def','cats','.').query
    assert query, "Should have generated a query"
  end
  
  def test_configuring_scanner_with_regex
    query = scanner_with('--def','/cats/','.').query
    assert query, "Should have generated a query"
  end
  
  def test_disabling_cache
    c = cli_with('--no-cache', '.')
    assert !c.cache_path
    assert !c.scanner.cache
  end
  
  def test_default_cache_behavior
    c = cli_with('.')
    assert c.cache_path
    assert c.scanner.cache
  end
  
  def test_custom_cache_path
    path = File.dirname(__FILE__) + '../lib'
    c = cli_with('--cache', path, '.')
    assert_equal path, c.cache_path
    assert c.scanner.cache
  end
  
  private
  def cli_with(*args)
    RubyScope::CLI.new(args)
  end
  
  def scanner_with(*args)
    cli_with(*args).scanner
  end
end