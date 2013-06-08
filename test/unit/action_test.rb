require File.expand_path '../../test_helper', __FILE__

class ActionTest < GistDep::TestCase::Unit

  def test_key
    assert_equal 'dummy', GistDep::Action::Dummy.key
  end

  def test_actions
    assert GistDep::Action.actions.include?(GistDep::Action::Dummy)
    assert !GistDep::Action.actions.include?(GistDep::Action::ForEach)
  end

end

class GistDep::Action::Dummy < GistDep::Action
  options do
    'foo'
  end
end
