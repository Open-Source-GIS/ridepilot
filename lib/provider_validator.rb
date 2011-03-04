class ProviderValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    if ! can? :manage, Provider.find(record.provider_id)
      record.errors[:provider_id] << "You can't manage that provider"
    end
  end
end

