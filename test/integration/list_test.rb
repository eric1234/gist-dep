require File.expand_path '../../test_helper', __FILE__

class ListTest < GistDep::TestCase::Integration

  def test_list
    copy_fixture_file 'list.yml', 'gist-dep.yml'

    assert_equal <<RESPONSE.chop, exec('list')
732081/engine_mixin.rb -> lib/engine_mixin.rb
519630/db_config.rb -> app/models/db_config.rb
519630/migration.rb -> db/migrations/20130509000000_add_db_config.rb
RESPONSE
  end

end
