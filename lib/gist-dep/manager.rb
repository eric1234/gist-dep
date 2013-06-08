require 'yaml'
require 'active_support/core_ext/class/attribute'

# The manager is responsible for determining what gists are part of
# the project. It is an in-memory representive of the config file.
class GistDep::Manager

  # Not a singleton class but actions interact with a single manager
  # which is tied to a specific project related file.
  class_attribute :instance
  attr_reader :files

  # Creates a new object to manage the list of gists installed
  def initialize config_path = 'gist-dep.yml'
    @files = []
    @config_path = config_path
    load
  end

  # Finds the files identified by the given gist id or gist id + filename
  # Always returns an array even if only one file found.
  def find id
    gist_id, filename = *id.split('/', 2)
    files.find_all do |file|
      file.gist_id == gist_id &&
      (filename.nil? || (filename == file.filename))
    end
  end

  # Will add the given gist file to the list of files being managed.
  # Adding a file to the manager will force the file to be stored if
  # the file is not already downloaded
  def add file
    file.download unless file.downloaded?
    @files << file
  end

  # Will remove the file from the list of files being managed. Calling
  # this will force the file to be deleted from the filesystem.
  def remove file
    file.delete
    @files -= [file]
  end

  # Persists the list of installed files (and other config) to
  # the config file.
  def save
    open @config_path, 'w' do |io|
      io.write({'files' => @files.collect(&:to_hash)}.to_yaml)
    end
  end

  # Establishes the global "instance" that all actions use to interact
  # with a specific projects config file.
  def self.load config_path
    self.instance = new config_path
  end

  private

  # Will load all config data from the config file
  def load
    return unless File.exist? @config_path
    @files = YAML.load_file(@config_path)['files'].collect do |file|
      GistDep::File.load file
    end
  end

end
