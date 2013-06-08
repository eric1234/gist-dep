require File.expand_path '../../../test_helper', __FILE__
require 'tempfile'

class DiffTest < GistDep::TestCase::Unit

  def test_run
    add_fixture '4063653', 'getHTML.coffee'

    expected = <<RESPONSE.chop
@@ -1,6 +1,6 @@
-Element.addMethods 'getHtml': (element) ->
   element = $ element
   if 'outerHTML' of doc.documentElement
     element.outerHTML
   else
-    doc.documentElement('html').update(element.cloneNode(true)).innerHTML
\\ No newline at end of file
+    doc.documentElement('html').update(element.cloneNode(true)).innerHTML
+Appended
RESPONSE

    assert_output expected do
      GistDep::Action::Diff.new.tap do |action|
        action.diff_cmd = 'diff -u'
        action.arguments = ['4063653']
      end.run
    end
  end

  private

  # Provides an alternate implementation of assert_output that reopens
  # stdout to a temp file and then compares against the file. This is
  # necessary because the diff tool is given full access to the normal
  # standard io. Redirection only takes place within a block.
  #
  # Also automatically discards the first two lines since the diff
  # output will change everytime for those lines.
  def assert_output output
    stdout = $stdout.dup
    Tempfile.open 'stdout-redirect' do |temp|
      $stdout.reopen temp.path, 'w'
      yield if block_given?
      $stdout.reopen stdout
      temp.rewind

      temp.readline; temp.readline
      assert_equal output, temp.read.chop
    end 
  end

end
