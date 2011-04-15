class Role < ActiveRecord::Base
  belongs_to :user
  belongs_to :provider

  def admin
    return level == 100
  end

  def editor
    return level >= 50
  end
end
