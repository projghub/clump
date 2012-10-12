class CreateLeadExports < ActiveRecord::Migration
  def change
    create_table :lead_exports do |t|
      t.integer :lead_id

      t.timestamps
    end
  end
end
