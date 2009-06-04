# Ruby DSL for generating CSS.
# Copyright (c) 2009 Tim Morgan

require File.dirname(__FILE__) + '/blankslate'

class CascadingRubies < BlankSlate

  [:class, :respond_to?, :inspect].each { |m| reveal(m) rescue nil }
  undef_method(:p)
  
  # list of tags taken from http://www.w3schools.com/tags/default.asp
  TAGS = %w(a abbr acronym address applet area b base basefont bdo big blockquote body br button caption center cite code col colgroup dd del dir div dfn dl dt em fieldset font form frame frameset h1toh6 head hr html i iframe img input ins isindex kbd label legend li link map menu meta noframes noscript object ol optgroup option p param pre q s samp script select small span strike strong style sub sup table tbody td textarea tfoot th thead title tr tt u ul var xmp)

  attr_reader :__selectors, :__css, :__context_name, :__has_children

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
  
  def method_missing(method_name, *args, &dsl_code)
    @__has_children = true
    selector = dsl_code ? __method_name_to_selector(method_name) : __dashify(method_name)
    s(selector, *args, &dsl_code)
  end

  def to_s
    @__selectors.join("\n")
  end
  
  def self.open(path)
    if (code = File.read(path)) =~ /^css do|CascadingRubies\.css do/
      eval(code)
    else
      css(code)
    end
    @obj
  end
  
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
