require File.expand_path '../../../test_helper', __FILE__

class UpdateTest < GistDep::TestCase::Unit

  def test_run
    add_fixture '732081', 'engine_mixin.rb'
    File.open('engine_mixin.rb', 'w') {|io| io.write 'old'}
    GistDep::Action::Update.new.tap {|a| a.arguments = ['732081']}.run
    assert_output "Downloading latest engine_mixin.rb from gist 732081"
    assert_file_contents 'Engine.mixin', 'engine_mixin.rb'
  end

end
