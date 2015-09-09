require 'minitest/autorun'
require 'metatext'
require 'redcarpet'

class MetaTextTest < Minitest::Test

  def test_vanilla_text
    use_txt_metatext!
    Metatext.parse :text do |meta, content|
      assert_equal meta, nil
      assert_equal content.strip, "hello world"
    end
  end

  def test_vanilla_text_with_dash_delimiters
    use_txt_metatext!
    Metatext.parse :text_with_dash_delimiters do |meta, content|
      assert_equal meta.foo, "hello"
      assert_equal meta.bar, "world"
      assert_equal content.strip, "hello world"
    end
  end

  def test_erb_with_dash_delimiters
    use_txt_erb_metatext!
    Metatext.parse :erb_with_dash_delimiters, foo: "iam", bar: "thecowgod" \
      do |meta, content|
        assert_equal meta.thing, "THECOWGOD"
        assert_equal content.strip, "iamthecowgodmoo"
    end
  end

  def test_markdown_with_dash_delimiters
    use_markdown_erb_metatext!
    Metatext.parse :markdown_erb_with_dash_delimiters, nums: (0..10).to_a \
      do |meta, content|
        assert_equal meta.thing, "hello world"
        assert_equal content.include?("<h1>markdown!</h1>"), true
        assert_equal content.include?("<li>number 8</li>"), true
    end
  end

  private

    def use_txt_metatext!
      Metatext.configure \
        dir: File.expand_path("../fixtures", __FILE__),
        ext: 'txt'
    end

    def use_txt_erb_metatext!
      Metatext.configure \
        dir: File.expand_path("../fixtures", __FILE__),
        ext: 'txt.erb'
    end

    def use_markdown_erb_metatext!
      Metatext.configure \
        dir: File.expand_path("../fixtures", __FILE__),
        ext: 'md.erb',
        processor: Redcarpet::Markdown.new(Redcarpet::Render::HTML)
    end
end
