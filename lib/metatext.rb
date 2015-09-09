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

    def configure(dir:, ext:, processor: nil)
      @dir = dir
      @ext = ext
      @pro = processor
    end

    # main driver method for metatext parsing
    # @return self

    def parse(file, locals={})
      raw = read file
      raw = erbify raw, with: locals if @ext.include? 'erb'
      yield metadata(raw), render(raw)
    end

    private

      # opens and reads the metatext file
      # @param file

      def read(file)
        File.read "#{@dir}/#{file.to_s}.#{@ext}"
      end

      # run the file contents through erb
      # @param with - the variables you want available in the file

      def erbify(raw, with:)
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
