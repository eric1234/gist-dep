require 'pathname'
require 'faraday_middleware'
require 'active_support/core_ext/class/attribute'

class GistDep::File

  class_attribute :downloader
  self.downloader = Faraday.new do |conn|
    conn.use FaradayMiddleware::FollowRedirects
    conn.adapter Faraday.default_adapter
  end

  class << self

    # Will fetch the gist file from http://gist.github.com.
    # The `id` can be one of two formats:
    #
    #     <gist_id>::
    #       All digits. Just the id of the gist. This assumes there is
    #       only one non-doc file in the gist.
    #     <gist_id>/<filename>::
    #       The gist id (all digits) followed by a slash followed by
    #       the name of the file desired. This is needed when there is
    #       more than one non-doc file in the gist.
    #
    # This method can throw the following exceptions:
    #
    #     ArgumentError::
    #       If the gist_id or filename is invalid this is thrown
    #     GistDep::TooManyFiles::
    #       Is thrown if only the gist_id is given and there is more
    #       than one non-doc file. Contains a list of files found. 
    def fetch id
      new.tap do |file|
        file.gist_id, file.filename = *id.split('/', 2)
        gist = GistDep::Gist.new file.gist_id

        if file.filename
          raise ArgumentError,
            "#{file.filename} not found in #{file.gist_id}" unless
            gist.filenames.include? file.filename
        else
          raise GistDep::TooManyFiles, gist.filenames if gist.filenames.size > 1
          file.filename = gist.filenames.first
        end
      end
    end

    # An internal method used to load the specs of a Gist File
    # from the configuration. Takes a hash and populates the object
    def load hash # :nodoc:
      new.tap do |file|
        for attribute in serialized_attributes
          file.send "#{attribute}=", hash[attribute]
        end
      end
    end

    # Internal method of all serialized attributes
    def serialized_attributes # :nodoc:
      %w(gist_id filename path)
    end

  end

  attr_accessor *serialized_attributes

  # Creates a new GistDep::File
  def initialize
    self.path = Dir.pwd
  end

  # Will assign the path ensuring it is relative to the current
  # working directory so we can move the project around and it won't
  # break links.
  def path= new_path
    new_path = Pathname.new new_path
    @path = if new_path.relative?
      new_path
    else
      new_path.relative_path_from Pathname.new(Dir.pwd)
    end.to_s
  end

  # Download the gist file to the location the `path` attribute points to.
  #
  # If `path` is a directory will place the file inside that
  # directory under the same name as in the Gist.
  #
  # If `path` is not a directory it will save the gist file as that
  # name (creating any directories as needed).
  #
  # In general you should always be able to download a gist since
  # the gist_id and the filename are validated when the gist is
  # fetched. But if the gist is removed between the time it is fetched
  # and when download is called an ArgumentError will be thrown just
  # like in fetch
  def download
    self.path = "#{path}/#{filename}" if File.directory? path
    FileUtils.mkdir_p File.dirname(path)
    open path, 'w' do |io|
      io.write self.class.downloader.get(url).body
    end
  end

  # Will indicate if this file has been persisted into the project
  def downloaded?
    File.file? path
  end

  # Will push changes back to the gist
  def save
    GistDep::Gist.client.edit_gist gist_id,
      files: {filename => {content: open(path).read}}
  end

  # Remove the file from the project
  def delete
    FileUtils.rm path
  end

  # An internal method to serizalize the specs of the file so it
  # can to serialized to the config file.
  def to_hash #:nodoc:
    self.class.serialized_attributes.inject({}) do |hash, attr|
      hash[attr] = send(attr).to_s
      hash
    end
  end

  private

  # Used by download to know where to download from. Will thrown an
  # ArgumentError if the gist or filename are not valid
  def url
    gist = GistDep::Gist.new gist_id
    gist.url_for filename or
      raise ArgumentError, "#{filename} not found in #{gist_id}"
  end

end
