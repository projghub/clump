class LeadExport < ActiveRecord::Base
  belongs_to :lead
  attr_accessible :lead_id
end
