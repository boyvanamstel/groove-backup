require 'open-uri'

module Backup
  class Downloader

    def initialize()
      @base_path = Utilities.create_folder(File.join('output','attachments'))
    end

    def download(message_id, attachment)
      download_path = File.join(Utilities.create_folder(File.join(@base_path, message_id)), attachment.filename)

      # Spawn a new thread
      File.open(download_path, 'wb') do |saved_file|
        # the following "open" is provided by open-uri
        open(attachment.url, 'rb') do |read_file|
          saved_file.write(read_file.read)
        end
      end
    end

  end
end

