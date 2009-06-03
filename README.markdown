# Cascading Rubies

Ruby DSL for generating CSS.

I wrote this small DSL because I like the concept of Sass -- just not
all the nuances of the syntax. I wondered how closely a Ruby DSL itself could
resemble final CSS output. This is the fruit of my experimentation.

I originally was going to call this RCSS, but that name is already taken.

Please note: This is very early beta, and the syntax may change. Also, this is
my very first DSL, and could very well be the biggest kludge you have ever seen.
But it works, and there's good test coverage, so hey.

## Syntax

    header {
      background_color '#eee'
      margin_bottom '10px'
      nav {
        border '1px solid #000'
        a(:link, :active, :visited) { color 'blue' }
        a(:hover) { color 'red' }
      }
      div.search {
        float 'right'
      }
    }
    
Output:

    #header { background-color: #eee; margin-bottom: 10px; }
    #header #nav { border: 1px solid #000; }
    #header #nav a:link, #header #nav a:active, #header #nav a:visited { color: blue; }
    #header #nav a:hover { color: red; }
    #header div.search { float: right; }
    
Since the syntax is just Ruby, you can add comments, variables, and do just about anything
you can in plain Ruby.

### Tags/IDs

Tags are determined from the array CascadingRubies::TAGS. If the name is present there, it is
assumed to be a tag -- otherwise the name is output as a selector `#id`.

### Classes

A leading underscore is used to denote a class selector, e.g. `_search { }` becomes
`.search { }` -- or you can put a tag in front of it like so: `div.search { }`.

### Comma-Separated Selectors

To output a comma-separated list of selectors, chain selectors together with semicolons
or newlines, like so: `li; a { }`.

### Examples

See example/example.rb for all the possible syntax, including use of the Sass
Color class for some color arithmetic.

## Installation

    sudo gem install seven1m-cascading_rubies -s http://gems.github.com
    
## Usage

The gem includes a binary called `rcss`. Run it without args for usage details.
Here are some examples:

    rcss base.rcss nav.rcss           # print both rendered css files to screen
    rcss -w base.rcss nav.rcss        # write rendered base.css and nav.css
    rcss base.rcss nav.rcss > all.css # write to single file
    rcss -w stylesheets               # render all .rcss files in directory
    
To use the library from within your own code:

    require 'rubygems'
    require 'cascading_rubies'
    
    css = CascadingRubies.parse(path_to_file)
    # or...
    css = CascadingRubies.new do
      # css here
    end
    
    rendered = css.to_s

## Shortcomings

There are lots, no doubt. Here are few I thought up just now:

* `s` is the method that builds selectors, so you can't specify an id #s directly
  in the DSL. Do this instead: `s('#s') { ... }`
* And there are a couple other methods you can't use as ids (unless you use `s`):
  * method\_name\_to\_selector
  * dashify
  * to\_s
* You can't build a selector like div#links without using the raw selector method:
  `s('div#links') { ... }`

## Feedback

I'd love to hear from you if you have suggestions for improvement, bug fixes,
or whatever. Email me at tim@timmorgan.org or fork the project and send a
pull request.

The library itself is less than a hundred lines; I hope that makes it fairly
easy to get started hacking on the project.

To run the tests, do this: `ruby test/test_cascading_rubies.rb`

The library has been tested with Ruby 1.8.7 and Ruby 1.9.0. If you find problems
with your Ruby of choice, please let me know.

## License

The MIT License

Copyright (c) 2009 Tim Morgan

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.

