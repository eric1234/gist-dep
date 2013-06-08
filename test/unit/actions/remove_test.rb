require File.expand_path '../../../test_helper', __FILE__

class RemoveTest < GistDep::TestCase::Unit

  def test_run
    add_fixture '732081', 'engine_mixin.rb'
    GistDep::Action::Remove.new.tap {|a| a.arguments = ['732081']}.run
    assert_output "Removing engine_mixin.rb"
    assert !File.exist?('engine_mixin.rb')
    assert_equal <<CONFIG, open('gist-dep.yml').read
---
files: []
CONFIG
  end

  def test_no_gist
    add_fixture '732081', 'engine_mixin.rb'
    assert_raises ArgumentError do
      GistDep::Action::Remove.new.run
    end
  end

end
