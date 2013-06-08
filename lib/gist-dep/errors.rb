 module GistDep

  # Thrown when a operation isn't specific enough and needs to know
  # which specific file.
  class TooManyFiles < StandardError

    attr_reader :files

    def initialize file_names
      @files = file_names
      super 'Operation not specific enough'
    end

  end

end
