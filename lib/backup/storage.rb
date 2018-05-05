require 'sqlite3'

class TrueClass def to_i() 1 end end
class FalseClass def to_i() 0 end end

module Backup
  class Storage 
    def initialize(output_path, client=nil)
      output_path = Utilities.create_folder(output_path)
      db_path = File.join(output_path, 'backup.db')
      @db = SQLite3::Database.new(db_path)

      @client = client
      @downloader = Downloader.new

      setup()
    end

    def retrieve_ticket(ticket_number)
      @db.execute("SELECT Ticket.title, Agent.email, Customer.email, Ticket.state FROM Ticket 
                  INNER JOIN Agent ON Ticket.agent_id = Agent.id
                  INNER JOIN Customer ON Ticket.customer_id = Customer.id
                  WHERE Ticket.number = ?", ticket_number)
    end

    def backup()

      # Fetch tickets
      @client.tickets(per_page: 50).each do |ticket|
        assignee = ticket.rels[:assignee]&.get
        customer = ticket.rels[:customer]&.get
        state = ticket.rels[:state]&.get

        store_ticket(assignee, customer, state, ticket)

        # Fetch messages
        ticket.rels[:messages].get.each do |message|
          from_customer = message.rels[:author]&.href.include?("/customers/")

          store_message(ticket.number, from_customer, message)

          # Fetch attachments
          message.rels[:attachments]&.get&.each do |attachment|

            store_attachment(message.id, attachment)

            # Don't download attachments for tickets marked as spam 
            break if state == "spam"
            download_attachment(message.id, attachment)

          end
        end
      end

    end

    def store_ticket(assignee, customer, state, ticket)
      @db.execute("INSERT OR REPLACE INTO Agent (id, email, first_name, last_name) 
                  VALUES (?, ?, ?, ?)", [assignee.id, assignee.email, assignee.first_name, assignee.last_name]) unless assignee.nil?

      @db.execute("INSERT OR REPLACE INTO Customer (id, email, name, about, twitter_username, title, company_name, phone_number, location, website_url, linkedin_username) 
                  VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)", [customer.id, customer.email, customer.name, customer.about, customer.twitter_username, customer.title, customer.company_name, customer.phone_number, customer.location, customer.website_url, customer.linkedin_username]) unless customer.nil?

      @db.execute("INSERT OR REPLACE INTO Ticket (created_at, number, resolution_time, title, updated_at, summary, state, customer_id, agent_id) 
                  VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)", [ticket.created_at, ticket.number, ticket.resolution_time, ticket.title, ticket.updated_at, ticket.summary, state, customer&.id, assignee&.id]) unless ticket.nil?
    end

    def store_message(ticket_number, from_customer, message)
      @db.execute("INSERT OR REPLACE INTO Message (id, created_at, updated_at, note, body, plain_text_body, from_customer, ticket_number) 
                  VALUES (?, ?, ?, ?, ?, ?, ?, ?)", [message.id, message.created_at, message.updated_at, message.note.to_i, message.body, message.plain_text_body, from_customer.to_i, ticket_number]) unless message.nil?
    end

    def store_attachment(message_id, attachment)
      @db.execute("INSERT OR REPLACE INTO Attachment (filename, url, message_id) 
                  VALUES (?, ?, ?)", [attachment.filename, attachment.url, message_id]) unless attachment.nil?
    end

    def download_attachment(message_id, attachment)
      @downloader.download(message_id, attachment)
    end

    def setup
      # Create a table
      @db.execute <<-SQL
  CREATE TABLE IF NOT EXISTS Ticket (
    created_at DATETIME,
    number INT PRIMARY KEY,
    resolution_time INT,
    title VARCHAR(255),
    updated_at DATETIME,
    summary VARCHAR(255),
    state VARCHAR(25),
    customer_id INT,
    agent_id INT,
    FOREIGN KEY(customer_id) REFERENCES Customer(id),
    FOREIGN KEY(agent_id) REFERENCES Agent(id)
  );
      SQL
      @db.execute <<-SQL
  CREATE TABLE IF NOT EXISTS Message (
    id INT PRIMARY KEY,
    created_at DATETIME,
    updated_at DATETIME,
    note BOOLEAN,
    body TEXT,
    plain_text_body TEXT,
    from_customer BOOLEAN,
    ticket_number INT,
    FOREIGN KEY(ticket_number) REFERENCES Ticket(number)
  );
      SQL
      @db.execute <<-SQL
  CREATE TABLE IF NOT EXISTS Customer (
    id INT PRIMARY KEY,
    email VARCHAR(255),
    name VARCHAR(255),
    about TEXT,
    twitter_username VARCHAR(255),
    title VARCHAR(255),
    company_name VARCHAR(255),
    phone_number VARCHAR(25),
    location VARCHAR(255),
    website_url VARCHAR(255),
    linkedin_username VARCHAR(255)
  );
      SQL
      @db.execute <<-SQL
  CREATE TABLE IF NOT EXISTS Agent (
    id INT PRIMARY KEY,
    email VARCHAR(255),
    first_name VARCHAR(255),
    last_name VARCHAR(255)
  );
      SQL
      @db.execute <<-SQL
  CREATE TABLE IF NOT EXISTS Attachment (
    filename VARCHAR(255),
    url VARCHAR(255) PRIMARY KEY,
    message_id INT,
    FOREIGN KEY(message_id) REFERENCES Message(id)
  );
      SQL
    end

    private :setup, :store_ticket, :store_message, :store_attachment

  end
end

