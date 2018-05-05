# Groove Ticket Backup

Retrieves all your tickets and messages from [Groove](https://www.groovehq.com) and stores them locally in an sqlite3 database. Attachments are downloaded separately.

## Usage

### Making a Backup

Clone the repo:
`$ git clone https://github.com/DangerCove/groove-backup.git`

Run the backup script:
```Bash
$ ./backup
Using concurrent-ruby 1.0.5
Using i18n 1.0.1
Using minitest 5.11.3
Using thread_safe 0.3.6
Using tzinfo 1.2.5
Using activesupport 5.2.0
Using bundler 1.16.1
Using multi_xml 0.6.0
Using httparty 0.16.2
Using groovehq 1.0.7 from https://github.com/Fodoj/groovehq.git (at master@6de06ea)
Using sqlite3 1.3.13
Bundle complete! 2 Gemfile dependencies, 11 gems now installed.
Use `bundle info [gemname]` to see where a bundled gem is installed.
Provide your Private Token:

```

^ Input your Private Token. [Can be found here](https://dangercove.groovehq.com/groove_client/settings/api).

Notice the `./output` folder appear while the script is running.

### Using the Backup

The script stores everything in an sqlite3 database, which can be queried with tools like [DB Browser for SQLite](http://sqlitebrowser.org/).

I started on a `retrieve` script, but I'm not sure if it'll be useful at all. Feel free to expand on it.

## Version History

### 0.1.0

* First release.
