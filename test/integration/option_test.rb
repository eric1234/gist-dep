require File.expand_path '../../test_helper', __FILE__

# Test misc command line options not tied to a specific subcommand
class OptionTest < GistDep::TestCase::Integration

  def test_config_file
    copy_fixture_file 'list.yml', 'config/gist-dep.yml'

    assert_equal <<RESPONSE.chop, exec(' -C config/gist-dep.yml list')
732081/engine_mixin.rb -> lib/engine_mixin.rb
519630/db_config.rb -> app/models/db_config.rb
519630/migration.rb -> db/migrations/20130509000000_add_db_config.rb
RESPONSE
  end

  def test_no_options
    assert_match /SYNOPSIS/, exec('')
  end

  def test_invalid_command
    assert_match /Unknown command/, exec('fake')
  end

end
