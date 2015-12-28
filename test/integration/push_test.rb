require File.expand_path '../../test_helper', __FILE__

require 'open-uri'

class PushTest < GistDep::TestCase::Integration

  def test_push
    dummy_gist do |gist|
      add_fixture gist.id, 'hello_world.rb'
      open('hello_world.rb', 'w') {|io| io.write 'puts "Ciao Mondo!"'}
      borrow_auth do
        assert_equal "hello_world.rb saved to gist #{gist.id}", exec("push #{gist.id}")
        assert_equal 'puts "Ciao Mondo!"',
          open(auth_client.gist(gist.id).files['hello_world.rb'].rels[:raw].href).read
      end
    end
  end

  def test_push_multiple
    dummy_gist 2 do |gist|
      copy_fixture_file 'push_multiple.yml', 'gist-dep.yml'
      updated = eval %Q{"#{open('gist-dep.yml').read}"}
      open('gist-dep.yml', 'w') {|io| io.write updated}
      copy_fixture_file 'hello_world.rb'
      copy_fixture_file '1.rb'

      open('hello_world.rb', 'w') {|io| io.write 'puts "Ciao Mondo!"'}
      open('1.rb', 'w') {|io| io.write 'puts "File uno"'}
      borrow_auth do
        assert_equal <<RESPONSE.chop, exec("push #{gist.id}")
hello_world.rb saved to gist #{gist.id}
1.rb saved to gist #{gist.id}
RESPONSE
      end
      assert_equal 'puts "Ciao Mondo!"',
        open(auth_client.gist(gist.id).files['hello_world.rb'].rels[:raw].href).read
      assert_equal 'puts "File uno"',
        open(auth_client.gist(gist.id).files['1.rb'].rels[:raw].href).read
    end
  end

  def test_fork
    new_id = nil
    add_fixture '5614994', 'hello_world.rb'
    open('hello_world.rb', 'w') {|io| io.write 'puts "Ciao Mondo!"'}
    borrow_auth do
      response = exec 'push 5614994'
      assert_match /hello_world\.rb fork saved to (\w+) from gist 5614994/, response
      new_id = response.scan(/saved to (\w+)/).first.first
      assert_equal 'puts "Ciao Mondo!"',
        open(auth_client.gist(new_id).files['hello_world.rb'].rels[:raw].href).read

      open('hello_world.rb', 'w') {|io| io.write 'puts "Hello World!"'}
      assert_match "hello_world.rb fork saved to #{new_id} from gist 5614994", exec('push 5614994')
      assert_equal 'puts "Hello World!"',
        open(auth_client.gist(new_id).files['hello_world.rb'].rels[:raw].href).read
    end
  ensure
    auth_client.delete_gist new_id if new_id
  end

  def test_not_found
    borrow_auth do
      # Purposely didn't install the gist
      assert_equal 'error: 732081 not found', exec('push 732081')
    end
  end

  def test_not_authenticated
    add_fixture '732081', 'engine_mixin.rb'
    assert_equal "error: You must login first", exec("push 732081")
  end

  def test_not_specified
    borrow_auth do
      assert_equal 'error: gist not specified', exec('push')
    end
  end

end
