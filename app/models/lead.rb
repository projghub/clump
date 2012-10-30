class Lead < ActiveRecord::Base
  before_save { |lead| lead.email = email.downcase }

  has_many :lead_exports

  attr_accessible :first_name, :last_name, :address, :address2, :city, :country, :gender, :postal_code, :region, :title, :email, :phone, :date_of_birth

  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :email, presence: true, format: { with: VALID_EMAIL_REGEX },
                    uniqueness: { case_sensitive: false }

  private

  def self.search(search)
    if search
      where('email LIKE ?', "%#{search}%")
    else
      scoped
    end
  end
end
