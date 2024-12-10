namespace :db do
  desc "Backup the database"
  task :backup => :environment do

    backup_dir = "db/backups"
    mkdir_p backup_dir

    db_config = ActiveRecord::Base.connection_db_config.configuration_hash
    db_name = db_config[:database]
    db_user = db_config[:username]
    db_password = db_config[:password]
    db_host = db_config[:host] || 'localhost'

    timestamp = Time.now.strftime("%Y%m%d%H%M%S")
    backup_file = "#{backup_dir}/backup_#{db_name}_#{timestamp}.sql"

    ENV['PGPASSWORD'] = db_password
    sh "pg_dump -Fc --no-acl --no-owner -h #{db_host} -U #{db_user} #{db_name} > #{backup_file}"
    puts "Database backup created: #{backup_file}"
  end

  desc "Restore the database from a backup file"
  task :restore, [:backup_file] => :environment do |t, args|

    if args[:backup_file].nil?
      puts "Usage: rake db:restore[backup_file]"
      exit 1
    end

    backup_file = args[:backup_file]
    unless File.exist?(backup_file)
      puts "Backup file not found: #{backup_file}"
      exit 1
    end

    db_config = ActiveRecord::Base.connection_db_config.configuration_hash
    db_name = db_config[:database]
    db_user = db_config[:username]
    db_password = db_config[:password]
    db_host = db_config[:host] || 'localhost'

    ENV['PGPASSWORD'] = db_password

    # Restore the database from the backup file
    puts "Restoring the database from the backup file..."
    sh "pg_restore --clean --no-acl --no-owner -h #{db_host} -U #{db_user} -d #{db_name} #{backup_file}"
    puts "Database restored from: #{backup_file}"
  end
end