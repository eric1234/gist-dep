require File.expand_path '../../test_helper', __FILE__

class ErrorsTest < GistDep::TestCase::Unit

  def test_initialization
    begin
      raise GistDep::TooManyFiles, ['db_config.rb', 'migration.rb']
    rescue GistDep::TooManyFiles
      assert_equal 'Operation not specific enough', $!.message
      assert_equal ['db_config.rb', 'migration.rb'], $!.files
    end
  end

end
