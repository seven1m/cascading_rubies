$: << File.expand_path(File.dirname(__FILE__) + '/../lib')

require 'cascading_rubies'
require 'test/unit'

class TestCascadingRubies < Test::Unit::TestCase
  
  # selectors

  def test_id_selector
    assert_produces "#nav { }", "nav { }"
  end
  
  def test_class_selector
    assert_produces ".links { }", "_links { }"
  end
  
  def test_class_selector_with_tag
    assert_produces "div.links { }", "div.links { }"
  end
  
  def test_tag_selector
    assert_produces "div { }", "div { }"
  end
  
  def test_raw_selector
    assert_produces "body>#content { }", "s('body>#content') { }"
    assert_produces "#s { }", "s('#s') { }"
  end
  
  def test_pseudo_class_selector
    assert_produces "a:link { }", "a(:link) { }"
    assert_produces "a:hover, a:active { }", "a(:hover, :active) { }"
  end
  
  # nesting
  
  def test_nested_selectors
    output = <<-CSS
      #header { }
      #header #nav { }
      #header #nav a { }
    CSS
    code = <<-CSS
      header {
        nav {
          a { }
        }
      }
    CSS
    assert_produces output.gsub(/^\s+/, '').chomp, code
  end
  
  def test_nested_pseudo_class_selector
    output = <<-CSS
      #header { }
      #header a:link { }
    CSS
    code = <<-CSS
      header {
        a(:link) { }
      }
    CSS
    assert_produces output.gsub(/^\s+/, '').chomp, code
  end
  
  # rules
  
  def test_underscores_replaced_with_dashes
    assert_produces "a { text-decoration: none; }", "a { text_decoration 'none' }"
  end
  
  def test_symbols_as_values
    assert_produces "a { text-decoration: none; }", "a { text_decoration :none }"
  end
  
  # misc
  
  def test_can_use_p_tag
    assert_produces "p { color: red; }", "p { color :red }"
  end
  
  private
    
    def assert_produces(output, code)
      @css = CascadingRubies.new
      @css.instance_eval(code)
      assert_equal output, @css.to_s
    end

end
