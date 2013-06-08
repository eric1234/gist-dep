require File.expand_path '../../test_helper', __FILE__

class RemoveTest < GistDep::TestCase::Integration

  def test_single_file_gist
    add_fixture '732081', 'engine_mixin.rb'
    assert_equal 'Removing engine_mixin.rb', exec('remove 732081')
    assert !File.exist?('engine_mixin.rb')
  end

  def test_specific_file
    copy_fixture_file 'gist-dep.yml'
    copy_fixture_file 'engine_mixin.rb'
    copy_fixture_file 'db_config.rb'
    copy_fixture_file 'migration.rb'
    assert_equal 'Removing migration.rb', exec('remove 519630/migration.rb')
    assert File.exist?('engine_mixin.rb')
    assert File.exist?('db_config.rb')
    assert !File.exist?('migration.rb')
  end

  def test_all_from_gist
    copy_fixture_file 'gist-dep.yml'
    copy_fixture_file 'engine_mixin.rb'
    copy_fixture_file 'db_config.rb'
    copy_fixture_file 'migration.rb'
    assert_equal <<RESPONSE.chop, exec('remove 519630')
Removing db_config.rb
Removing migration.rb
RESPONSE
    assert File.exist?('engine_mixin.rb')
    assert !File.exist?('db_config.rb')
    assert !File.exist?('migration.rb')
  end

  def test_gist_not_found
    # Purposely didn't install the gist
    assert_equal 'error: 732081 not found', exec('remove 732081')
  end

  def test_no_gist
    add_fixture '732081', 'engine_mixin.rb'
    assert_equal 'error: gist not specified', exec('remove')
  end

end
