require File.expand_path '../../test_helper', __FILE__

class ManagerTest < GistDep::TestCase::Unit

  def test_add
    manager = GistDep::Manager.new
    file = GistDep::File.load 'gist_id' => '732081',
      'filename' => 'engine_mixin.rb', 'path' => './engine_mixin.rb'
    fixture_file 'engine_mixin.rb'
    manager.add file
    assert_equal [file], manager.files
  end

  def test_find
    manager = GistDep::Manager.new fixture_file('gist-dep.yml') 
    assert_equal ['engine_mixin.rb'],
      manager.find('732081').collect(&:filename)
    assert_equal ['db_config.rb', 'migration.rb'],
      manager.find('519630').collect(&:filename)
    assert_equal ['migration.rb'],
      manager.find('519630/migration.rb').collect(&:filename)
  end

  def test_remove
    manager = GistDep::Manager.new
    file = GistDep::File.fetch '732081'
    manager.add file
    assert File.exist?('engine_mixin.rb')
    manager.remove file
    assert !File.exist?('engine_mixin.rb')
    assert_equal [], manager.files
  end

  def test_instantionate
    open('gist-dep.yml', 'w') do |io|
      io.write <<CONFIG
---
files:
- gist_id: '732081'
  filename: engine_mixin.rb
  path: lib/engine_mixin.rb
- gist_id: '519630'
  filename: db_config.rb
  path: app/models/db_config.rb
- gist_id: '519630'
  filename: migration.rb
  path: db/migrations/20130509000000_add_db_config.rb
CONFIG
    end

    manager = GistDep::Manager.new

    assert_equal '732081', manager.files[0].gist_id
    assert_equal 'engine_mixin.rb', manager.files[0].filename
    assert_equal 'lib/engine_mixin.rb', manager.files[0].path

    assert_equal '519630', manager.files[1].gist_id
    assert_equal 'db_config.rb', manager.files[1].filename
    assert_equal 'app/models/db_config.rb', manager.files[1].path

    assert_equal '519630', manager.files[2].gist_id
    assert_equal 'migration.rb', manager.files[2].filename
    assert_equal 'db/migrations/20130509000000_add_db_config.rb', manager.files[2].path
  end

  def test_save
    manager = GistDep::Manager.new
    FileUtils.mkdir_p 'lib'
    FileUtils.mkdir_p 'app/models'

    f1 = GistDep::File.fetch '732081'
    f1.path = 'lib'
    manager.add f1

    f2 = GistDep::File.fetch '519630/db_config.rb'
    f2.path = 'app/models'
    manager.add f2
    
    f3 = GistDep::File.fetch '519630/migration.rb'
    f3.path = 'db/migrations/20130509000000_add_db_config.rb'
    manager.add f3

    manager.save
    assert_equal <<CONFIG, open('gist-dep.yml').read
---
files:
- gist_id: '732081'
  filename: engine_mixin.rb
  path: lib/engine_mixin.rb
- gist_id: '519630'
  filename: db_config.rb
  path: app/models/db_config.rb
- gist_id: '519630'
  filename: migration.rb
  path: db/migrations/20130509000000_add_db_config.rb
CONFIG
  end

end
