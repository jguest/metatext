## metatext

a lightweight jekyll-inspired metadata processor

### what it do

* parses yaml at the top of any file, jekyll style
* stores metadata in an object
* inject your own text processor (e.g. redcarpet for markdown)
* use erb (<% %>) for dynamic text on demand

### getting started

Install the gem with by running `gem install metatext` or include it in your Gemfile.

configure metatext

```ruby
Metatext.configure(dir: File.expand_path("examples", __FILE__), ext: 'txt')
```

hello_word.txt

```
---
foo: hello
bar: world
---
hello world
```

use it

```ruby
Metatext.parse :hello_word do |meta, content|
  puts meta.inspect # => #<OpenStruct foo="hello", bar="world">
  puts content      # => "hello world"
end
```

### erb on demand

If you set your extension to anything ending with `.erb`, e.g. `txt.erb`, the
text will be processed as erb, also allowing you to pass in locals.

```
---
foo: hello
bar: world
---
<% sounds.each do |sound| %>
  <%= sound %>!
<% end %>
```

and the ruby

```ruby
Metatext.parse :hello_word, sounds: ["bleep", "bloop"] do |meta, content|
  puts meta.inspect # => #<OpenStruct foo="hello", bar="world">
  puts content      # => "hello world"
end
```

### with markdown

If you'd like to process the text as markdown as well, a la Jekyll, just add it to
`#configure` like so:

```ruby
Metatext.configure(
  dir: File.expand_path("examples", __FILE__),
  ext: 'md.erb',
  processor: Redcarpet::Markdown.new(Redcarpet::Render::HTML))
```

Note: any text processor will work **as long as it implements a `render` method**.

### why?

This library was originally written for no-fuss, plaintext email templates. It was developed
for and used in production environments at [CD Baby](http://www.cdbaby.com/).
