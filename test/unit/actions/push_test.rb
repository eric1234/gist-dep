require File.expand_path '../../../test_helper', __FILE__

require 'open-uri'

class PushTest < GistDep::TestCase::Unit

  def test_run
    dummy_gist do |gist|
      borrow_auth do
        # Fake like we already have the gist downloaded so we can
        # try pushing changes.
        file = GistDep::File.load 'gist_id' => gist.id,
          'filename' => 'hello_world.rb', 'path' => './hello_world.rb'
        GistDep::Manager.instance.files << file
        open('hello_world.rb', 'w') {|io| io.write 'puts "Ciao Mondo!"'}

        # Sent update to dummy gist
        GistDep::Action::Push.new.tap {|a| a.arguments = [gist.id]}.run
        assert_output "hello_world.rb saved to gist #{gist.id}"
        assert_equal 'puts "Ciao Mondo!"',
          open(auth_client.gist(gist.id).files['hello_world.rb'].rels[:raw].href).read
      end
    end
  end

  def test_fork
    new_id = nil

    borrow_auth do
      # Pretend the anonymous gist is already installed
      file = GistDep::File.load 'gist_id' => '5614994',
        'filename' => 'hello_world.rb', 'path' => './hello_world.rb'
      GistDep::Manager.instance.files << file
      open('hello_world.rb', 'w') {|io| io.write 'puts "Ciao Mondo!"'}

      # Save gist which should create fork
      GistDep::Action::Push.new.tap {|a| a.arguments = ['5614994']}.run
      assert_output /hello_world\.rb fork saved to (\d+) from gist 5614994/
      new_id = @out.string.scan(/saved to (\d+)/).first.first
      assert_equal 'puts "Ciao Mondo!"',
        open(auth_client.gist(new_id).files['hello_world.rb'].rels[:raw].href).read
      clear_output

      # Save gist again which should update fork
      open('hello_world.rb', 'w') {|io| io.write 'puts "Hello World!"'}
      GistDep::Action::Push.new.tap {|a| a.arguments = ['5614994']}.run
      assert_output "hello_world.rb fork saved to #{new_id} from gist 5614994"
      assert_equal 'puts "Hello World!"',
        open(auth_client.gist(new_id).files['hello_world.rb'].rels[:raw].href).read
    end

  ensure
    auth_client.delete_gist new_id if new_id
  end

  def test_no_gist
    add_fixture '732081', 'engine_mixin.rb'
    assert_raises ArgumentError do
      GistDep::Action::Push.new.run
    end
  end

end
