require 'octokit'
require 'yaml'

class GistDep::Action::Login < GistDep::Action

  self.desc = 'Authenticates gist-dep'
  self.desc_long = <<-DESC
    Once authenticated you can access private gists, push gist changes
    and have less chance of being rate limited.
  DESC

  def run
    if GistDep::Gist.client.oauthed?
      self.class.io.say "WARNING: Already logged in"
      return
    end

    login = self.class.io.ask 'Enter your username/e-mail: '
    password = self.class.io.ask('Enter your password: ') {|q| q.echo = 'x'}

    begin
      client = Octokit::Client.new login: login, password: password
      token = client.create_authorization(scopes: ['gist'], note: 'GistDep').token

      config_file = "#{ENV['HOME']}/.gist-dep.yml"
      config = if File.exists? config_file
        YAML.load_file config_file
      else
        {}
      end
      config[:token] = token.to_s
      open(config_file, 'w') do |io|
        File.chmod 0600, io.path
        io.write config.to_yaml
      end

      self.class.io.say "\ngit-dep is now authenticated"
    rescue Octokit::Unauthorized
      self.class.io.say "\ncredentials invalid"
    end
  end

end
