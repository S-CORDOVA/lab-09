class OwnerPolicy < ApplicationPolicy
  def index?
    admin?
  end

  def show?
    admin? || own_record?
  end

  def create?
    admin?
  end

  def update?
    admin? || own_record?
  end

  def destroy?
    admin?
  end

  def permitted_attributes
    if admin?
      [:first_name, :last_name, :email, :phone, :address, :user_id]
    elsif owner? && own_record?
      [:first_name, :last_name, :email, :phone, :address]
    else
      []
    end
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      if admin?
        scope.all
      elsif owner?
        scope.where(user_id: user.id)
      else
        scope.none
      end
    end
  end

  private

  def own_record?
    record.user_id == user.id
  end
end