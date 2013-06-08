require File.expand_path '../../../test_helper', __FILE__

class ForEachTest < GistDep::TestCase::Unit

  def test_single_file
    add_fixture '732081', 'engine_mixin.rb'

    GistDep::Action::ForEach.new.tap {|a| a.arguments = ['732081']}.run do |file|
      @out.puts "Doing something with #{file.filename}"
    end
    assert_output "Doing something with engine_mixin.rb"
  end

  def test_specific_file
    add_fixture '519630', 'db_config.rb'
    add_fixture '519630', 'migration.rb'

    GistDep::Action::ForEach.new.tap {|a| a.arguments = ['519630/migration.rb']}.run do |file|
      @out.puts "Doing something with #{file.filename}"
    end
    assert_output "Doing something with migration.rb"
  end

  def test_all_from_gist
    add_fixture '519630', 'db_config.rb'
    add_fixture '519630', 'migration.rb'

    GistDep::Action::ForEach.new.tap {|a| a.arguments = ['519630']}.run do |file|
      @out.puts "Doing something with #{file.filename}"
    end
    assert_output <<RESPONSE.chop
Doing something with db_config.rb
Doing something with migration.rb
RESPONSE
  end

  def test_all
    add_fixture '732081', 'engine_mixin.rb'
    add_fixture '519630', 'db_config.rb'
    add_fixture '519630', 'migration.rb'

    GistDep::Action::ForEach.new.run do |file|
      @out.puts "Doing something with #{file.filename}"
    end
    assert_output <<RESPONSE.chop
Doing something with engine_mixin.rb
Doing something with db_config.rb
Doing something with migration.rb
RESPONSE
  end

  def test_invalid
    # Purposely didn't install any gists
    assert_raises ArgumentError do
      GistDep::Action::ForEach.new.tap {|a| a.arguments = ['732081']}.run
    end
  end

end
