class CreateLeads < ActiveRecord::Migration
  def up
    create_table :leads do |t|
      t.string :first_name
      t.string :middle_name
      t.string :last_name
      t.string :title
      t.string :gender
      t.string :date_of_birth
      t.string :address
      t.string :address2
      t.string :city
      t.string :region
      t.string :postal_code
      t.string :country
      t.string :phone
      t.string :email
      t.string :offer_id
      t.string :pub_id
      t.string :sub_id
      t.string :url
      t.string :ip_address
      t.datetime :acquired_at

      t.timestamps
    end
  end

  def down
    drop_table :leads
  end
end
