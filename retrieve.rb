require_relative 'lib/backup'

storage = Backup::Storage.new('output')

storage.retrieve_ticket(205).each do |ticket|
  puts ticket
end

