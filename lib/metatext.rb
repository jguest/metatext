require 'yaml'
require 'erb'
require 'ostruct'

# MetaText
# a lightweight jekyll-style metadata parser
#
# [what it do]
#
# * parses yaml at the top of any file, jekyll style
# * stores metadata in an object
# * inject your own text processor (e.g. redcarpet for markdown)
# * use erb (<% %>) for dynamic text on demand
#
# @author jguest

class Metatext
  class << self

    # @param dir - path to metatext files
    # @param ext - the file extention (e.g. 'txt', 'md', 'txt.erb')
    # @param processor - any object that responds to `#render`

    def configure(dir: nil, ext: nil, processor: nil)
      @dir = dir
      @ext = ext
      @pro = processor
    end

    # main driver method for metatext parsing
    # @return self

    def parse(to_parse, locals={})
      raw = read(to_parse) || to_parse
      raw = erbify raw, with: locals if parse_as_erb? raw
      yield metadata(raw), render(raw)
    end

    private

      # opens and reads the metatext file
      # @param file

      def read(to_parse)
        if to_parse.is_a? Symbol
          File.read "#{@dir}/#{to_parse.to_s}.#{@ext}"
        end
      end

      # run raw content through erb?
      # @param raw

      def parse_as_erb?(raw)
        (@ext && @ext.include?("erb")) || (@ext.nil? && raw.include?("<%"))
      end

      # run the file contents through erb
      # @param with - the variables you want available in the file

      def erbify(raw, with: {})
        namespace = OpenStruct.new with
        ERB.new(raw).result namespace.instance_eval { binding }
      end

      # get metadata with yaml in-between "---"
      # @param raw

      def metadata(raw)
        raw.match data_regex
        OpenStruct.new YAML.load($1) if $1
      end

      # get content with everything but yaml section
      # @param raw

      def render(raw)
        content = raw.gsub data_regex, "" || raw
        return @pro.render content if @pro
        content
      end

      # a regex for "---- some metadata --- the real content"
      # @return regular expression

      def data_regex
        /^(---\s*\n.*?\n?)^(---\s*$\n?)/m
      end
  end
end
