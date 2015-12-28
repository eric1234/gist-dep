require File.expand_path '../../../test_helper', __FILE__

class AddTest < GistDep::TestCase::Unit

  def test_basic
    GistDep::Action::Add.new.tap {|a| a.arguments = ['732081']}.run
    assert_output 'Adding engine_mixin.rb from gist 732081'
    assert_file_contents 'Engine.mixin', 'engine_mixin.rb'
    assert_file_contents <<CONFIG, 'gist-dep.yml'
---
files:
- gist_id: '732081'
  filename: engine_mixin.rb
  path: "./engine_mixin.rb"
CONFIG
  end

  def test_path
    FileUtils.mkdir_p 'app/assets/javascripts'
    GistDep::Action::Add.new.tap do |action|
      action.arguments = ['795566']
      action.path = 'app/assets/javascripts'
    end.run
    assert_output 'Adding placeholder.coffee from gist 795566 to app/assets/javascripts'
    assert_file_contents 'placeholder', 'app/assets/javascripts/placeholder.coffee'
  end

  def test_specified_file
    GistDep::Action::Add.new.tap {|a| a.arguments = ['519630/db_config.rb']}.run
    assert_output 'Adding db_config.rb from gist 519630'
    assert_file_contents 'DbConfig', 'db_config.rb'
  end

  def test_not_specific_enough
    begin
      GistDep::Action::Add.new.tap {|a| a.arguments = ['519630']}.run
    rescue EOFError
    end
    assert_output <<RESPONSE.chop
1. db_config.rb
2. db_config_test.rb
3. migration.rb
Please choose the file you wish to import?
RESPONSE
  end

  def test_select_from_menu
    @in << "1\n"
    @in.rewind
    GistDep::Action::Add.new.tap {|a| a.arguments = ['519630']}.run
    assert_output <<RESPONSE.chop
1. db_config.rb
2. db_config_test.rb
3. migration.rb
Please choose the file you wish to import?
Adding db_config.rb from gist 519630
RESPONSE
    assert_file_contents 'DbConfig', 'db_config.rb'

    @in.truncate @in.rewind
    @out.truncate @out.rewind

    @in << "3\n"
    @in.rewind
    GistDep::Action::Add.new.tap {|a| a.arguments = ['519630']}.run
    assert_output <<RESPONSE.chop
1. db_config.rb
2. db_config_test.rb
3. migration.rb
Please choose the file you wish to import?
Adding migration.rb from gist 519630
RESPONSE
    assert_file_contents 'AddConfig', 'migration.rb'
  end

end
