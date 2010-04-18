require 'test/test_helper'

# Self referential testing! 
# These are awesome, absurd, and abusive. 
# Make sure that the app actually does what we say it does.
class ConsoleTest < Test::Unit::TestCase
  ROOT = File.dirname(__FILE__) + '/../../'
  
  def test_finding_this_test
    res = rs "--def '/^test/'"
    assert_success
    assert res['test_finding_this_test'], "Should have found this test"
  end
  
  def test_finding_assignment
    self_referential_line_number = __LINE__
    
    res = rs "--assign self_referential_line_number"
    assert_success
    assert res.split("\n").last =~ /(\d+)\:\s+self_referential_line_number = __LINE__/
    assert_equal self_referential_line_number, $1.to_i
  end
  
  def test_reading_the_help_and_making_queries
    help = rs "--help"
    assert help =~ /Queries:(.+)\s+Options:/m, "Should have a queries section"
    queries = $1
    queries.split("\n").each do |query|
      next if query =~ /^\s*$/
      assert query =~ /(--\S+)\s+(\S+)?/, "Each query should be a long flag with an optional parameter\n#{query.inspect}"
      flag, param_type = $1,$2
      param = case param_type
        when 'NAME'       then  "a"
        when 'SEXP_PATH'  then  "'s()'"
        else                    nil
      end
      
      res = rs "#{flag} #{param}"
      assert_success res
    end
  end
  
  private
  def rs(args)
    `#{ROOT}bin/ruby_scope --no-cache #{args} #{__FILE__}`
  end
  
  def assert_success(msg=nil)
    assert $?.success?, msg||"Exited with status #{$?.exitstatus}"
  end
end