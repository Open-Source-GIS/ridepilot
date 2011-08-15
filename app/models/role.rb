class Role < ActiveRecord::Base
  belongs_to :user
  belongs_to :provider
  validates_uniqueness_of :user_id, :scope=>:provider_id

  def admin?
    return level == 100
  end

  def editor?
    return level >= 50
  end

  def name
    if level == 100
      return 'Admin'
    elsif level == 50
      return 'Editor'
    else
      return 'User'
    end
  end

end
