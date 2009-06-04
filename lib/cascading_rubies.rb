# Ruby DSL for generating CSS.
# Copyright (c) 2009 Tim Morgan

require File.dirname(__FILE__) + '/blankslate'

class CascadingRubies < BlankSlate #:doc:

  [:class, :respond_to?, :inspect].each { |m| reveal(m) rescue nil }
  undef_method(:p)
  
  # List of tags taken from http://www.w3schools.com/tags/default.asp
  TAGS = %w(a abbr acronym address applet area b base basefont bdo big blockquote body br button caption center cite code col colgroup dd del dir div dfn dl dt em fieldset font form frame frameset h1toh6 head hr html i iframe img input ins isindex kbd label legend li link map menu meta noframes noscript object ol optgroup option p param pre q s samp script select small span strike strong style sub sup table tbody td textarea tfoot th thead title tr tt u ul var xmp)

  attr_reader :__selectors, :__css, :__context_name, :__has_children #:nodoc:

  # Creates a CascadingRubies object. Normally, you should not pass in any arguments,
  # except a block of style definitions. The block can optionally take a single argument --
  # if so, the newly created object is yielded to the block, and instance_eval is not used.
  # 
  # Each block in the style definitions is effectively going to trigger a new object to
  # be created, so the block argument is optional <em>for each block</em>, and the determination to
  # use instance_eval is subsequently <em>per block</em>:
  #     CascadingRubies.new do |css|
  #       css.header do |header|
  #         header.background_color '#ccc'
  #       end
  #       css.p {
  #         margin_bottom '15px'
  #       }
  #     end
  #
  # If you do not pass a block (or even if you do), you can execute additional style definitions
  # by either calling methods directly on the object:
  #     obj = CascadingRubies.new
  #     obj.nav { margin '10px'; a { color :red } }
  # or you can instance_eval another block of code:
  #     obj.instance_eval do
  #       p { margin_bottom '15px' }
  #     end
  def initialize(context_name=nil, selectors=[], classed=false, &dsl_code)
    @__context_name = context_name
    @__css = ''
    @__selectors = selectors
    @__classed = classed # if true, method_missing calls are css class selectors -- not id selectors
    if dsl_code.nil?
      # do nothing
    elsif dsl_code.arity == 1
      dsl_code[self]
    else
      instance_eval(&dsl_code)
    end
  end
  
  # Create a new style "selector" without going through method_missing.
  # Use this to create style definitions that cannot be created with the DSL directly, e.g.
  # * <tt>s('##s') { color :blue }</tt> => <tt>##s { color: blue; }</tt>
  # * <tt>s('div##search') { margin 0 }</tt> => <tt>div##search { margin: 0; }</tt>
  def s(selector, *args, &dsl_code)
    if args.any? and dsl_code.nil? # css rule
      @__css << "#{selector}: #{args.join(' ')}; "
    else
      if args.any? and dsl_code # pseudo-class selector
        selector_name = args.map do |arg|
          [[@__context_name, selector].compact.join(' '), ':' + arg.to_s].join('')
        end.join(', ')
      else # regular selector
        selector_name = [@__context_name, selector].compact.join(@__classed ? '' : ' ')
      end
      if @__bare and not @__bare.__has_children # e.g. li; a { }
        selector_name = "#{@__bare.__context_name}, #{selector_name}"
      end
      if dsl_code
        compiled = self.class.new(selector_name, &dsl_code)
        @__selectors << "#{selector_name} { #{compiled.__css}}" unless compiled.__css.empty?
        @__selectors += compiled.__selectors
        @__bare = nil
      else # e.g. div.something
        @__bare = self.class.new(selector_name, @__selectors, true, &dsl_code)
      end
    end
  end
  
  def method_missing(method_name, *args, &dsl_code) #:nodoc:
    @__has_children = true
    selector = dsl_code ? __method_name_to_selector(method_name) : __dashify(method_name)
    s(selector, *args, &dsl_code)
  end

  # Returns the complete CSS style definitions as a string.
  def to_s
    @__selectors.join("\n")
  end
  
  # Creates a CascadingRubies object, then opens the file and executes the style
  # definitions in the context of the object. Returns the newly created object.
  def self.open(path)
    if (code = File.read(path)) =~ /^css do|CascadingRubies\.css do/
      eval(code)
    else
      css(code)
    end
    @obj
  end
  
  # Wraps the creation of a CascadingRubies object and doing the instance_eval execution
  # in a neat package for use inside rcss files. An rcss file can use the optional block
  # syntax to wrap style definitions, allowing code to be run outside the instance_eval
  # confines. Use this method in an .rcss file like so:
  #     css do
  #       a { color :red }
  #     end
  # or:
  #     CascadingRubies.css do
  #       a { color :red }
  #     end
  def self.css(code=nil, &block)
    @obj = self.new
    if code
      @obj.instance_eval(code)
    else
      @obj.instance_eval(&block)
    end
  end
  
  private
  
    def __method_name_to_selector(method_name)
      selector = method_name.to_s
      if selector.sub!(/^_/, '.')
        __dashify(selector)
      elsif TAGS.include?(selector)
        __dashify(selector)
      elsif @__classed
        '.' + __dashify(selector)
      else
        '#' + __dashify(selector)
      end
    end
    
    def __dashify(name)
      name.to_s.gsub(/_/, '-').downcase
    end

end
