class FundingSource < ActiveRecord::Base
  has_many :funding_source_visibilities
  has_many :providers, :through=>:funding_source_visibilities
  validates_presence_of :name
  validates_length_of :name, :minimum=>2

  def self.by_provider(provider)
    return FundingSource.find(:all, :joins=>:funding_source_visibilities, :conditions=>["funding_source_visibilities.provider_id = ?", provider.id])
  end
end
