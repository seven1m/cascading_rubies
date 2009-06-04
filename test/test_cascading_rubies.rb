$: << File.expand_path(File.dirname(__FILE__) + '/../lib')

require 'cascading_rubies'
require 'test/unit'

class TestCascadingRubies < Test::Unit::TestCase
  
  # selectors

  def test_id_selector
    assert_produces "#nav { color: red; }", "nav { color :red }"
  end
  
  def test_class_selector
    assert_produces ".links { color: red; }", "_links { color :red }"
  end
  
  def test_class_selector_with_tag
    assert_produces "div.links { color: red; }", "div.links { color :red }"
  end
  
  def test_tag_selector
    assert_produces "div { color: red; }", "div { color :red }"
  end
  
  def test_raw_selector
    assert_produces "body>#content { color: red; }", "s('body>#content') { color :red }"
    assert_produces "#s { color: red; }", "s('#s') { color :red }"
  end
  
  def test_pseudo_class_selector
    assert_produces "a:link { color: red; }", "a(:link) { color :red }"
    assert_produces "a:hover, a:active { color: red; }", "a(:hover, :active) { color :red }"
  end
  
  def test_multiple_comma_separated_selectors
    assert_produces "#nav li, #nav a { color: red; }", "nav { li; a { color :red } }" # double
    assert_produces "#nav li, #nav div, #nav a { color: red; }", "nav { li; div; a { color :red } }" # triple
    output = <<-CSS
      #nav li, #nav a:link, #nav a:visited { color: red; }
      #nav a { color: green; }
    CSS
    code = <<-CSS
      nav {
        li; a(:link, :visited) {
          color :red
        }
        a {
          color :green
        }
      }
    CSS
    assert_produces output.gsub(/^\s+/, '').chomp, code # following selector isn't affected
  end
  
  def test_empty_selectors_not_printed
    assert_produces "#nav li { color: red; }", "nav { li { color :red } }"
  end
  
  # nesting
  
  def test_nested_selectors
    output = <<-CSS
      #header { color: red; }
      #header #nav { color: blue; }
      #header #nav a { color: green; }
    CSS
    code = <<-CSS
      header {
        color :red
        nav {
          color :blue
          a {
            color :green
          }
        }
      }
    CSS
    assert_produces output.gsub(/^\s+/, '').chomp, code
  end
  
  def test_nested_pseudo_class_selector
    output = <<-CSS
      #header { color: red; }
      #header a:link { color: blue; }
    CSS
    code = <<-CSS
      header {
        color :red
        a(:link) {
          color :blue
        }
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
  
  def test_use_p_tag
    assert_produces "p { color: red; }", "p { color :red }"
  end
  
  def test_puts
    assert_produces "a { color: red; }", "a { color :red }"
    assert_nothing_raised do
      puts @css
    end
  end
  
  def test_examples
    Dir[File.dirname(__FILE__) + '/../example/*.rcss'].each do |path|
      assert_nothing_raised do
        @css = CascadingRubies.open(path)
      end
      assert @css.to_s != ''
    end
  end
  
  private
    
    def assert_produces(output, code)
      @css = CascadingRubies.new
      @css.instance_eval(code)
      assert_equal output, @css.to_s
    end

end
