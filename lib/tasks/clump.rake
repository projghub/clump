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
    task :export_to_DISPATCH, [:host, :port, :token, :path, :limit, :chunk] => :environment do |task_name, arguments|

      require 'net/http'
      require 'json'

      arguments.with_defaults(host: 'lvh.me', port: '80', token: 'abc1234', path: '/api/leads/new', limit: 1, chunk: 1)
      host = arguments[:host]
      port = arguments[:port]
      token = arguments[:token]
      path = arguments[:path]
      limit = arguments[:limit]
      chunk = arguments[:chunk]
      
      puts arguments.inspect

      ActiveRecord::Base.establish_connection()

      limit.to_i.times do
        lead = Lead.select('leads.first_name, leads.last_name, leads.address, leads.city, leads.region, leads.postal_code, leads.country, leads.email, leads.phone')
                   .joins('LEFT JOIN lead_exports')
                   .where('lead_exports.id IS NULL')
                   .order('leads.created_at DESC')
                   .limit(chunk)

        puts lead.inspect

        request = Net::HTTP::Post.new(path, initheader = {'Content-Type' =>'application/json'})
        request.body = {
          'token' => token,
          'data' => lead
        }.to_json

        puts request.body.inspect
        response = Net::HTTP.new(host, port).start {|http| http.request(request) }
        puts "Response #{response.code} #{response.message}: #{response.body}"
        if response.code == 200
          sql = "
           INSERT INTO lead_exports (lead_id, created_at, updated_at)
           VALUES (#{lead_id}, '#{time}', '#{time}')
          "
          puts sql
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
          puts "DELETING: "  + lead.id.to_s
          lead.destroy
        end
      end
    end

    desc 'find and remove bogus emails'
    task :remove_bogus_emails => :environment do |task_name|
      ActiveRecord::Base.establish_connection()

      bogus_emails = ['test', 'bgbng.com', 'campheroes.com', 'asdf', 'taige']

      bogus_emails.each do |email|
        Lead.where('email LIKE ?', "%#{email}%").destroy_all()
        puts "DELETING emails LIKE: " + email
      end
    end

  end
end
