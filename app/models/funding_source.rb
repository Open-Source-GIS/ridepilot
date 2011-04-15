class FundingSource < ActiveRecord::Base
  has_many :funding_source_visibilities
  has_many :providers, :through=>:funding_source_visibilities
  validates_presence_of :name
  validates_length_of :name, :minimum=>2
end
