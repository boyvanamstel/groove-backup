require 'fileutils'

module Backup
  class Utilities

    def self.create_folder(path)
      FileUtils.mkdir_p(path) unless File.directory?(path)

      path 
    end

  end
end

