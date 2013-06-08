require File.expand_path '../../test_helper', __FILE__

class AddTest < GistDep::TestCase::Integration

  def test_basic_addition 
    assert_equal 'Adding engine_mixin.rb from gist 732081', exec('add 732081')
    assert_file_contents 'Engine.mixin', 'engine_mixin.rb'
    assert_file_contents <<CONFIG, 'gist-dep.yml'
---
files:
- gist_id: '732081'
  filename: engine_mixin.rb
  path: ./engine_mixin.rb
CONFIG
    assert_equal 'Adding random.coffee from gist 3315166', exec('add 3315166')
    assert_match 'Array.prototype.random', open('random.coffee').read
  end

  def test_add_to_directory
    FileUtils.mkdir_p 'app/assets/javascripts'
    response = exec 'add --path app/assets/javascripts 795566'
    assert_equal 'Adding placeholder.coffee from gist 795566 to app/assets/javascripts', response
    assert_match 'placeholder', open('app/assets/javascripts/placeholder.coffee').read
  end

  def test_rename
    response = exec 'add --path lib/engine_ext.rb 732081'
    assert_equal 'Adding engine_mixin.rb from gist 732081 to lib/engine_ext.rb', response
    assert_file_contents 'Engine.mixin', 'lib/engine_ext.rb'
  end

  def test_specified_file
    response = exec 'add 519630/db_config.rb'
    assert_equal 'Adding db_config.rb from gist 519630', response
    assert_file_contents 'DbConfig', 'db_config.rb'
  end

  def test_doc_ignore
    assert_equal 'Adding required.coffee from gist 4237367', exec('add 4237367')
    assert_file_contents 'required', 'required.coffee'
  end

  def test_query
    response = exec 'add 519630 < /dev/null'
    assert_equal <<RESPONSE.chop, response
1. db_config.rb
2. migration.rb
Please choose the file you wish to import?
RESPONSE

    response = exec 'add 519630', prefix: 'echo 1 | '
    assert_equal <<RESPONSE.chop, response
1. db_config.rb
2. migration.rb
Please choose the file you wish to import?
Adding db_config.rb from gist 519630
RESPONSE
    assert_file_contents 'DbConfig', 'db_config.rb'

    response = exec 'add 519630', prefix: 'echo 2 | '
    assert_equal <<RESPONSE.chop, response
1. db_config.rb
2. migration.rb
Please choose the file you wish to import?
Adding migration.rb from gist 519630
RESPONSE
    assert_file_contents 'AddConfig', 'migration.rb'
  end

  def test_invalid_commands
    assert_equal 'error: gist not specified', exec("add")
    assert_equal 'error: abc gist invalid', exec("add abc")
    assert_equal 'error: invalid.rb not found in 519630', exec("add 519630/invalid.rb")
  end

  def test_duplicate_add
    add_fixture '732081', 'engine_mixin.rb'
    assert_equal 'error: engine_mixin.rb from gist 732081 already installed', exec("add 732081")
    assert_file_contents <<CONFIG, 'gist-dep.yml'
---
files:
- gist_id: '732081'
  filename: engine_mixin.rb
  path: ./engine_mixin.rb
CONFIG
  end

end
