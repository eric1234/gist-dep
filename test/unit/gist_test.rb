require File.expand_path '../../test_helper', __FILE__

class GistTest < GistDep::TestCase::Unit

  def test_invalid
    assert_raises ArgumentError do
      GistDep::Gist.new 'abc'
    end
  end

  def test_owner
    assert_equal 'eric1234', GistDep::Gist.new('4237367').owner
  end

  def test_fork_by
    fork = GistDep::Gist.new('294896').fork_by 'eric1234'
    assert_equal '4063653', fork.id
    assert_equal 'eric1234', fork.owner
  end

  def test_filenames
    assert_equal %w(required.coffee),
      GistDep::Gist.new('4237367').filenames
    assert_equal %w(db_config.rb db_config_test.rb migration.rb),
      GistDep::Gist.new('519630').filenames
  end

  def test_url_for
    expected = 'https://gist.githubusercontent.com/eric1234/519630/raw/765f1cf96e81306d42b8c83fca6a952604e8780e/db_config.rb'
    assert_equal expected,
      GistDep::Gist.new('519630').url_for('db_config.rb')
    assert_nil GistDep::Gist.new('519630').url_for('fake.rb')
  end

end
