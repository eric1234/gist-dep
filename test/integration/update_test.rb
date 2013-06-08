require File.expand_path '../../test_helper', __FILE__

class UpdateTest < GistDep::TestCase::Integration

  def test_single_file_gist
    add_fixture '732081', 'engine_mixin.rb'
    File.open('engine_mixin.rb', 'w') {|io| io.write 'old'}
    assert_equal 'Downloading latest engine_mixin.rb from gist 732081', exec('update 732081')
    assert_file_contents 'Engine.mixin', 'engine_mixin.rb'
  end

  def test_specific_file
    fixtures
    assert_equal 'Downloading latest migration.rb from gist 519630', exec('update 519630/migration.rb')
    assert_file_contents 'AddConfig', 'migration.rb'
    assert_file_contents 'old2', 'db_config.rb'
    assert_file_contents 'old3', 'engine_mixin.rb'
  end

  def test_all_from_gist
    fixtures
    assert_equal <<RESPONSE.chop, exec('update 519630')
Downloading latest db_config.rb from gist 519630
Downloading latest migration.rb from gist 519630
RESPONSE
    assert_file_contents 'DbConfig', 'db_config.rb'
    assert_file_contents 'AddConfig', 'migration.rb'
    assert_file_contents 'old3', 'engine_mixin.rb'
  end

  def test_all
    fixtures
    assert_equal <<RESPONSE.chop, exec('update')
Downloading latest engine_mixin.rb from gist 732081
Downloading latest db_config.rb from gist 519630
Downloading latest migration.rb from gist 519630
RESPONSE
    assert_file_contents 'Engine.mixin', 'engine_mixin.rb'
    assert_file_contents 'DbConfig', 'db_config.rb'
    assert_file_contents 'AddConfig', 'migration.rb'
  end

  def test_gist_not_found
    assert_equal 'error: 732081 not found', exec('update 732081')
  end

  private

  def fixtures
    copy_fixture_file 'gist-dep.yml'
    copy_fixture_file 'engine_mixin.rb'
    copy_fixture_file 'db_config.rb'
    copy_fixture_file 'migration.rb'
    File.open('migration.rb', 'w') {|io| io.write 'old1'}
    File.open('db_config.rb', 'w') {|io| io.write 'old2'}
    File.open('engine_mixin.rb', 'w') {|io| io.write 'old3'}
  end

end
