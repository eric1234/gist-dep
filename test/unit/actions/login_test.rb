require File.expand_path '../../../test_helper', __FILE__

class LoginTest < GistDep::TestCase::Unit

  def test_valid_login
    skip 'Redundent authorizations not longer allowed'

    @in << "#{ENV['GITHUB_LOGIN']}\n#{ENV['GITHUB_PASSWORD']}"
    @in.rewind
    GistDep::Action::Login.new.run
    assert_output <<RESPONSE.chop
Enter your username/e-mail: Enter your password: #{'x' * ENV['GITHUB_PASSWORD'].length}

git-dep is now authenticated
RESPONSE

    config = YAML.load_file "#{ENV['HOME']}/.gist-dep.yml"
    assert_match /\w{40}/, config[:token]
  end

  def test_invalid_login
    @in << "#{ENV['GITHUB_LOGIN']}\ninvalid"
    @in.rewind
    begin
      GistDep::Action::Login.new.run
      assert_output <<RESPONSE.chop
Enter your username/e-mail: Enter your password: xxxxxxx

credentials invalid
RESPONSE
    rescue Octokit::Forbidden
      skip "invalid login test skipped due to too many attempts"
    end
  end

  def test_already_logged_in
    borrow_auth do
      @in << "#{ENV['GITHUB_LOGIN']}\ninvalid"
      @in.rewind
      GistDep::Action::Login.new.run
      assert_output "WARNING: Already logged in"
    end
  end

end
