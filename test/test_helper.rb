require 'minitest/autorun'
require 'tmpdir'
require 'stringio'
require 'fileutils'

Bundler.require :default, :development
Dotenv.load

$LOAD_PATH << File.expand_path('../../lib', __FILE__)
require 'gist-dep'

class GistDep::TestCase < Minitest::Test

  # We need to isolate each test to avoid the tests interacting with
  # the user's current directory and real credentials (unless we
  # specifically want them to)
  #
  # Reassign ENV['HOME'] to an isolated directory
  # Re-asssign current working directory to isolated directory
  def setup
    super
    @old_home, ENV['HOME'] = ENV['HOME'], Dir.mktmpdir
    @old_pwd, @pwd = Dir.pwd, Dir.mktmpdir
    Dir.chdir @pwd
  end

  # Restores the current working directory and ENV['HOME'] (see setup).
  # Cleans up the temp directories created and also cleans up any
  # authorizations we created on GitHub.
  def teardown
    cleanup_token # In case we created an authorization
    FileUtils.remove_entry_secure ENV['HOME'] if ENV['HOME'].start_with? '/tmp'
    FileUtils.remove_entry_secure @pwd if @pwd.start_with? '/tmp'
    ENV['HOME'] = @old_home
    Dir.chdir @old_pwd
    super
  end

  # Will borrow the current users "real" authorization to use as a
  # fixture (this way we don't have to include a real authorization in
  # our fixtures). After the block exits it automatically cleans out
  # the token from our temp home directory so the teardown doesn't
  # unauthorize a real token.
  def borrow_auth
    token_file = File.join @old_home, '.gist-dep.yml'
    skip "real home must be logged in for this test" unless File.exist? token_file
    FileUtils.cp token_file, "#{ENV['HOME']}/.gist-dep.yml"
    yield
  ensure
    FileUtils.rm "#{ENV['HOME']}/.gist-dep.yml"
  end

  # Will simulate a gist-dep add using fixtures
  def add_fixture gist_id, filename, path="./#{filename}"
    if caller(1, 1).first =~ /integration/
      # If integration testing the copy fixture file so manager can
      # load it.
      open('gist-dep.yml', 'w+') do |io|
        io.write <<YAML
---
files:
- gist_id: '#{gist_id}'
  filename: #{filename}
  path: #{path}
YAML
      end
    else
      # If unit testing just adjust in-memory objects to simulate
      # the manager having already had them
      file = GistDep::File.load 'gist_id' => gist_id,
        'filename' => filename, 'path' => path
      GistDep::Manager.instance.files << file
    end
    copy_fixture_file File.basename(path)
  end

  # Determines the full path to the given fixture file.
  def fixture_file file
    fixture_dir = File.expand_path '../fixtures', __FILE__
    File.join fixture_dir, file
  end

  # Will copy the specified fixture file to the specified location
  # (defaults to the current working directory)
  def copy_fixture_file file, to=Dir.pwd
    FileUtils.mkdir_p File.dirname(to)
    FileUtils.cp fixture_file(file), to
  end

  # Test that the file has the expected contents
  def assert_file_contents expected, file
    assert_match expected, open(file).read
  end

  # Will create a dummy gist and pass it into a block. Automatically
  # cleans up gist after the block
  def dummy_gist file_count=1
    files = {"hello_world.rb" => {content: 'puts "Hello World!"'}}
    (1...file_count).each do |idx|
      files["#{idx}.rb"] = {content: %Q[puts "File #{idx}"]}
    end
    gist = auth_client.create_gist \
      description: 'Test for gist-dep', public: true, files: files
    yield gist
  ensure
    auth_client.delete_gist gist.id if gist
  end

  # Will remove the given token from Github (to cleanup after tests).
  # If a token is not given then it reads from the gist-dep config
  # file.
  def cleanup_token token=nil
    unless token
      config_file = "#{ENV['HOME']}/.gist-dep.yml"
      return unless File.exist? config_file
      token = YAML.load_file(config_file)[:token]
    end
    for auth in auth_client.authorizations
      auth_client.delete_authorization auth.id if auth.token == token
    end
  end

  # Will return a Github client that is fully authenticated
  def auth_client
    @auth_client ||=
      Octokit::Client.new login: ENV['GITHUB_LOGIN'], password: ENV['GITHUB_PASSWORD']
  end

end

class GistDep::TestCase::Unit < GistDep::TestCase

  def setup
    super

    # Setup clean manager instance with each test
    GistDep::Manager.instance = GistDep::Manager.new

    # Redirect stdin/stdout so we can read it for appropiate values
    @in, @out = StringIO.new, StringIO.new
    GistDep::Action.io = HighLine.new(@in, @out)
  end

  # Will erase any output to clean up for further commands
  def clear_output
    @out.truncate @out.rewind
  end

  # Test that the output from gist-dep matches the expected value
  def assert_output expected
    assert_match expected, @out.string.chop
  end

end

class GistDep::TestCase::Integration < GistDep::TestCase

  # Will run the gist-dep exec with the given arguments in the isolated
  # environment. Can also provide a block to run before the command
  # (in the isolated environment) and a prefix to the exec
  def exec args, prefix: ''
    exec = File.expand_path '../../bin/gist-dep', __FILE__
    `#{prefix} #{exec} #{args} 2>&1`.chop
  end

end
