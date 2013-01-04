def clean_up_data(key, value)
  if key == 'first_name'
    value = value.capitalize
  end

  if key == 'last_name'
    value = value.capitalize
  end

  if key == 'phone'
    value = value.gsub(/[^0-9]/, '')
    value = value[1..-1] if value[0,1] == '1'
  end

  if key == 'email'
    value = value.downcase
  end

  value
end

namespace :clump do
  namespace :leads do

    desc 'Import leads from a csv into database'
    task :import, [:filename] => :environment do |task_name, arguments|
      require 'csv'
      arguments.with_defaults(filename: 'leads.csv')
      filename = 'lib/assets/' + arguments.filename
      puts "Importing: #{filename}"
      ActiveRecord::Base.establish_connection()
      headers = [ 'first_name', 'last_name', 'address', 'city', 'region', 'country', 'postal_code', 'phone' , 'email', 'offer_id', 'url', 'pub_id', 'sub_id', 'ip_address', 'acquired_at' ]

      CSV.open(filename, 'r').each do |record|
        #puts record.inspect
        sql_keys = []
        sql_vals = []

        time = Time.now.strftime("%Y-%m-%d %H:%M:%S")

        headers.each_with_index do |key, index|
          value = clean_up_data(key, record[index])
          sql_keys << key
          sql_vals << ActiveRecord::Base.connection.quote(value)
        end

        sql = "
          INSERT INTO leads (#{sql_keys.join(', ')}, created_at, updated_at)
          VALUES (#{sql_vals.join(', ')}, '#{time}', '#{time}')
        "
        #puts sql

        result = ActiveRecord::Base.connection.execute(sql)
        lead_id = ActiveRecord::Base.connection.last_inserted_id(result)
        puts "ADDED: " + lead_id.to_s
      end
    end

    desc 'Find data that has not been exported and send them to DISPATCH'
    task :export_to_DISPATCH, [:host, :port, :token, :path, :limit] => :environment do |task_name, arguments|

      require 'net/http'
      require 'json'

      arguments.with_defaults(host: 'lvh.me', port: '80', token: 'abc1234', path: '/api/leads/create', limit: 1)
      host = arguments[:host]
      port = arguments[:port]
      token = arguments[:token]
      path = arguments[:path]
      limit = arguments[:limit]
      
      #puts arguments.inspect

      ActiveRecord::Base.establish_connection()

      limit.to_i.times do
        lead = Lead.select('leads.id, leads.first_name, leads.last_name, leads.address, leads.city, leads.region, leads.postal_code, leads.country, leads.email, leads.phone')
                   .joins('LEFT JOIN lead_exports ON lead_exports.lead_id = leads.id')
                   .where('lead_exports.id IS NULL')
                   .first

        new_customer = lead.attributes

        request = Net::HTTP::Post.new(path)
        request["Content-Type"] = "application/json"
        request["Authorization"] = "Token token=#{token}"

        request.body = {
          'customer' => new_customer
        }.to_json

        #puts request.inspect
        response = Net::HTTP.new(host, port).start {|http| http.request(request) }
        #puts "Response #{response.code} #{response.message}: #{response.body}"
        #puts "REPONSE CODE: " + response.code
        if response.code == '201'
          time = Time.now.strftime("%Y-%m-%d %H:%M:%S")

          sql = "
           INSERT INTO lead_exports (lead_id, created_at, updated_at)
           VALUES (#{lead.id}, '#{time}', '#{time}')
          "
          #puts sql
          result = ActiveRecord::Base.connection.execute(sql)
        end
      end
    end

    desc 'find and remove duplicates (email)'
    task :remove_duplicate_emails => :environment do |task_name|
      # do a query and count the email address?
      # pull every record and look for a duplicate in the database?
      ActiveRecord::Base.establish_connection()
      sql = "
        SELECT COUNT(*) AS total, email FROM leads
        GROUP BY email
        HAVING COUNT(*) > 1
      "
      #puts sql
      result = ActiveRecord::Base.connection.execute(sql)

      result.each do |record|
        leads = Lead.select('id').where(email: record["email"]).order("created_at DESC")
        #puts leads.inspect

        leads[1..(leads.count - 1)].each do |lead|
          puts "DELETING ("  + lead.id.to_s + "): " + record["email"]
          lead.destroy
        end
      end
    end

    desc 'find and remove bogus emails'
    task :remove_bogus_info => :environment do |task_name|
      ActiveRecord::Base.establish_connection()

      bogus_emails = ['test', 'bgbng.com', 'campheroes.com', 'asdf', 'taige', '.gov', 'downington', 'fuck', 'pussy', 'scam', ',', '`', '[', ']', ';', 'a@b.com', 'attorney', '!', '#', '~', 'novagroup', 'dskadk', 'l.park@novagrou']

      bogus_emails.each do |email|
        Lead.where('email LIKE ?', "%#{email}%").destroy_all()
        puts "DELETING emails LIKE: " + email
      end

      bogus_names = ['Test']

      bogus_names.each do |name|
        Lead.where('first_name LIKE ?', "%#{name}%").destroy_all()
        puts "DELETING names LIKE: " + name 
      end

      bogus_phones = ['99999', '88888', '77777', '66666', '55555', '44444', '33333', '22222', '11111', '1234']

      bogus_phones.each do |phone|
        Lead.where('phone LIKE ?', "%#{phone}%").destroy_all()
        puts "DELETING phones LIKE: " + phone
      end


    end

  end
end
