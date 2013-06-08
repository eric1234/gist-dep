require File.expand_path '../../test_helper', __FILE__

class DiffTest < GistDep::TestCase::Integration

  def test_single_file_gist
    add_fixture '4063653', 'getHTML.coffee'
    copy_fixture_file 'getHTML.coffee'
    assert_equal <<RESPONSE.chop, exec('diff 4063653')
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
  end

  def test_specific_file
    copy_fixture_file '4667599.yml', 'gist-dep.yml'
    copy_fixture_file 'assign.worker'
    copy_fixture_file 'list.worker'
    assert_equal <<RESPONSE.chop, exec('diff 4667599/list.worker')
@@ -1,6 +1,6 @@
-runtime \"php\"
 exec 'list.php'
 file 'connect.php'
 file 'iron.json'
 file 'aws.phar'
 file 'iron_worker.phar'
+Appended
RESPONSE
  end

  def test_all_from_gist
    copy_fixture_file '4667599.yml', 'gist-dep.yml'
    copy_fixture_file 'assign.worker'
    copy_fixture_file 'list.worker'
    assert_equal <<RESPONSE.chop, exec('diff 4667599')
@@ -1,4 +1,4 @@
-runtime \"php\"
 exec 'assign.php'
 file 'connect.php'
 file 'aws.phar'
+Appended
@@ -1,6 +1,6 @@
-runtime \"php\"
 exec 'list.php'
 file 'connect.php'
 file 'iron.json'
 file 'aws.phar'
 file 'iron_worker.phar'
+Appended
RESPONSE
  end

  def test_all
    copy_fixture_file 'diff_all.yml', 'gist-dep.yml'
    copy_fixture_file 'getHTML.coffee'
    copy_fixture_file 'assign.worker'
    copy_fixture_file 'list.worker'
    assert_equal <<RESPONSE.chop, exec('diff')
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
@@ -1,4 +1,4 @@
-runtime \"php\"
 exec 'assign.php'
 file 'connect.php'
 file 'aws.phar'
+Appended
@@ -1,6 +1,6 @@
-runtime \"php\"
 exec 'list.php'
 file 'connect.php'
 file 'iron.json'
 file 'aws.phar'
 file 'iron_worker.phar'
+Appended
RESPONSE
  end

  def test_alternate_diff
    add_fixture '4063653', 'getHTML.coffee'
    copy_fixture_file 'getHTML.coffee'
    response = exec 'diff --diff_cmd diff 4063653'
    assert_equal <<RESPONSE.chop, response
1d0
< Element.addMethods 'getHtml': (element) ->
6c5,6
<     doc.documentElement('html').update(element.cloneNode(true)).innerHTML
\\ No newline at end of file
---
>     doc.documentElement('html').update(element.cloneNode(true)).innerHTML
> Appended
RESPONSE
  end

  def test_gist_not_found
    assert_equal 'error: 732081 not found', exec('diff 732081')
  end

  private

  # Override to throw away the file names since they will differ
  # on every diff run.
  def exec *args, &blk
    super(*args).gsub(/^-{3} .*\n/, '').gsub /^\+{3} .*\n/, ''
  end

end
