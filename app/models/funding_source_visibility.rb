class FundingSourceVisibility < ActiveRecord::Base
  belongs_to :provider
  belongs_to :funding_source
end
