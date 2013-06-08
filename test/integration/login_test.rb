require File.expand_path '../../test_helper', __FILE__

class LoginTest < GistDep::TestCase::Integration

  def test_valid_login
    input = "#{ENV['GITHUB_LOGIN']}\n#{ENV['GITHUB_PASSWORD']}"
    response = exec 'login', prefix: %Q{echo "#{input}" | }
    response.gsub! 'stty: standard input: Inappropriate ioctl for device', ''

    assert_equal <<RESPONSE.chop, response
Enter your username/e-mail: Enter your password: 

#{'x' * ENV['GITHUB_PASSWORD'].length}


git-dep is now authenticated
RESPONSE

    config = YAML.load_file "#{ENV['HOME']}/.gist-dep.yml"
    assert_match ENV['GITHUB_LOGIN'], config[:login]
    assert_match /\w{40}/, config[:token]
  end

  def test_invalid_login
    input = "#{ENV['GITHUB_LOGIN']}\ninvalid"
    response = exec 'login', prefix: %Q{echo "#{input}" | }
    response.gsub! 'stty: standard input: Inappropriate ioctl for device', ''

    if response =~ /Octokit\:\:Forbidden/
      skip "invalid login test skipped due to too many attempts"
    else
      assert_equal <<RESPONSE.chop, response
Enter your username/e-mail: Enter your password: 

xxxxxxx


credentials invalid
RESPONSE
    end
  end

  def test_already_logged_in
    borrow_auth do
      assert_equal "WARNING: Already logged in", exec('login')
    end
  end

end
