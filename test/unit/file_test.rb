require File.expand_path '../../test_helper', __FILE__

require 'open-uri'

class GistFileTest < GistDep::TestCase::Unit

  def test_fetch
    file = GistDep::File.fetch '732081'
    assert_equal '732081', file.gist_id
    assert_equal 'engine_mixin.rb', file.filename
  end

  def test_fetch_specific_file
    file = GistDep::File.fetch '519630/db_config.rb'
    assert_equal 'db_config.rb', file.filename

    file = GistDep::File.fetch '519630/migration.rb'
    assert_equal 'migration.rb', file.filename
  end

  def test_fetch_ignoring_docs
    file = GistDep::File.fetch '4237367'
    assert_equal 'required.coffee', file.filename
  end

  def test_fetch_invalid
    assert_raises ArgumentError do
      GistDep::File.fetch 'abc'
    end
    assert_raises ArgumentError do
      GistDep::File.fetch '519630/invalid.rb'
    end
  end

  def test_not_specific_enough
    assert_raises GistDep::TooManyFiles do
      GistDep::File.fetch '519630'
    end
  end

  def test_load
    file = GistDep::File.load 'gist_id' => '732081',
      'filename' => 'engine_mixin.rb', 'path' => 'lib/engine_mixin.rb'
    assert_equal '732081', file.gist_id
    assert_equal 'engine_mixin.rb', file.filename
    assert_equal 'lib/engine_mixin.rb', file.path
  end

  def test_to_hash
    file = GistDep::File.load 'gist_id' => '732081',
      'filename' => 'engine_mixin.rb', 'path' => 'lib/engine_mixin.rb'
    expected = {
      'gist_id' => '732081',
      'filename' => 'engine_mixin.rb',
      'path' => 'lib/engine_mixin.rb'
    }
    assert_equal expected, file.to_hash
  end

  def test_download_default_location
    GistDep::File.load('gist_id' => '732081',
      'filename' => 'engine_mixin.rb', 'path' => '.').download
    assert_file_contents 'Engine.mixin', 'engine_mixin.rb'
  end

  def test_download_specified_directory
    FileUtils.mkdir_p 'app/assets/javascripts'
    GistDep::File.load('gist_id' => '795566',
      'filename' => 'placeholder.coffee',
      'path' => 'app/assets/javascripts').download
    assert_file_contents 'placeholder', 'app/assets/javascripts/placeholder.coffee'
  end

  def test_download_rename
    GistDep::File.load('gist_id' => '732081',
      'filename' => 'engine_mixin.rb',
      'path' => 'lib/engine_ext.rb').download
    assert_file_contents 'Engine.mixin', 'lib/engine_ext.rb'
  end

  def test_downloaded?
    file = GistDep::File.load 'gist_id' => '732081',
      'filename' => 'engine_mixin.rb', 'path' => '.'
    assert !file.downloaded?
    file.download
    assert file.downloaded?
  end

  def test_delete
    file = GistDep::File.load 'gist_id' => '732081',
      'filename' => 'engine_mixin.rb', 'path' => './engine_mixin.rb'
    copy_fixture_file 'engine_mixin.rb'
    assert File.exist?('engine_mixin.rb')
    file.delete
    assert !File.exist?('engine_mixin.rb')
  end

  def test_save
    dummy_gist do |gist|
      file = GistDep::File.load 'gist_id' => gist.id,
        'filename' => 'hello_world.rb', 'path' => './hello_world.rb'
      open('hello_world.rb', 'w') {|io| io.write 'puts "Ciao Mondo!"'}
      file.save
      assert_equal 'puts "Ciao Mondo!"',
        open(auth_client.gist(gist.id).files['hello_world.rb'].rels[:raw].href).read
    end
  end

end
