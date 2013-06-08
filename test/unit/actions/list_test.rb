require File.expand_path '../../../test_helper', __FILE__

class ListTest < GistDep::TestCase::Unit

  def test_basic
    GistDep::Manager.instance =
      GistDep::Manager.new fixture_file('list.yml') 

    GistDep::Action::List.new.run

    assert_output <<RESPONSE.chop
732081/engine_mixin.rb -> lib/engine_mixin.rb
519630/db_config.rb -> app/models/db_config.rb
519630/migration.rb -> db/migrations/20130509000000_add_db_config.rb
RESPONSE
  end

end
