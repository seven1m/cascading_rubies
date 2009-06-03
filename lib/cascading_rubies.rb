# Ruby DSL for generating CSS.
# Copyright (c) 2009 Tim Morgan

class CascadingRubies

  undef_method('p')

  # list of tags taken from http://www.w3schools.com/tags/default.asp
  TAGS = %w(a abbr acronym address applet area b base basefont bdo big blockquote body br button caption center cite code col colgroup dd del dir div dfn dl dt em fieldset font form frame frameset h1toh6 head hr html i iframe img input ins isindex kbd label legend li link map menu meta noframes noscript object ol optgroup option p param pre q s samp script select small span strike strong style sub sup table tbody td textarea tfoot th thead title tr tt u ul var xmp)

  attr_reader :selectors, :css, :context_name, :has_children

  def initialize(context_name=nil, selectors=[], classed=false, &dsl_code)
    @context_name = context_name
    @css = ''
    @selectors = selectors
    @classed = classed # if true, method_missing calls are css class selectors -- not id selectors
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
      @css << "#{selector}: #{args.join(' ')}; "
    else
      if args.any? and dsl_code # pseudo-class selector
        selector_name = args.map do |arg|
          [[@context_name, selector].compact.join(' '), ':' + arg.to_s].join('')
        end.join(', ')
      else # regular selector
        selector_name = [@context_name, selector].compact.join(@classed ? '' : ' ')
      end
      if @bare and not @bare.has_children # e.g. li; a { }
        selector_name = "#{@bare.context_name}, #{selector_name}"
      end
      if dsl_code
        compiled = self.class.new(selector_name, &dsl_code)
        @selectors << "#{selector_name} { #{compiled.css}}" unless compiled.css.empty?
        @selectors += compiled.selectors
        @bare = nil
      else # e.g. div.something
        @bare = self.class.new(selector_name, @selectors, true, &dsl_code)
      end
    end
  end
  
  def method_missing(method_name, *args, &dsl_code)
    @has_children = true
    selector = dsl_code ? method_name_to_selector(method_name) : dashify(method_name)
    s(selector, *args, &dsl_code)
  end

  def to_s
    @selectors.join("\n")
  end
  
  def self.parse(path)
    obj = self.new
    obj.instance_eval(File.read(path))
    obj
  end
  
  private
  
    def method_name_to_selector(method_name)
      selector = method_name.to_s
      if selector.sub!(/^_/, '.')
        dashify(selector)
      elsif TAGS.include?(selector)
        dashify(selector)
      elsif @classed
        '.' + dashify(selector)
      else
        '#' + dashify(selector)
      end
    end
    
    def dashify(name)
      name.to_s.gsub(/_/, '-').downcase
    end

end
