require 'octokit'
require 'active_support/core_ext/object/try'

# A small wrapper around the GitHub API wrapper (i.e. octokit).
#
# Provides the info we need in the format we need.
#
# Will help to abstract us from octokit so if we decide to switch
# wrappers (or just use raw HTTP).
class GistDep::Gist

  attr_reader :id

  # A reference to our GitHub API wrapper. Will used stored token
  # in home directory for authenticated requests unless it is invalid
  # or doesn't exist.
  def self.client
    begin
      config_file = "#{ENV['HOME']}/.gist-dep.yml"
      token = YAML.load_file(config_file)[:token]
      Octokit::Client.new access_token: token
    rescue Errno::ENOENT
      if ENV['GITHUB_LOGIN'] && ENV['GITHUB_PASSWORD']
        # This is just for testing so we can avoid rate limiting
        Octokit::Client.new login: ENV['GITHUB_LOGIN'], password: ENV['GITHUB_PASSWORD']
      else
        Octokit
      end
    end
  end

  # Find the gist by the given id. Throw an ArgumentError if not found
  def initialize gist_id
    @id = gist_id
    begin
      @gist = GistDep::Gist.client.gist @id
    rescue Octokit::NotFound
      raise ArgumentError, "#{gist_id} gist invalid"
    end
  end

  # The owner of this gist
  def owner
    @gist.user.login if @gist.user
  end

  # Will get the fork by the given username
  def fork_by username
    fork = @gist.forks.find {|f| f.user.login == username}.try(:id)
    GistDep::Gist.new fork if fork
  end

  # Will get the url to the given file on the gist
  def url_for filename
    @gist.files[filename].try :raw_url
  end

  # Returns the name of all non-doc files in the gist
  def filenames
    @filenames ||= @gist.files.values.collect(&:filename).reject do |filename|
      ext = File.extname(filename)[1..-1]
      filename == 'README' || doc_extensions.include?(ext)
    end
  end

  # Based on https://github.com/github/markup#markups
  def doc_extensions
    %w(markdown mdown md textile rdoc org creole mediawiki rst asciidoc pod)
  end

end
