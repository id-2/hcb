# frozen_string_literal: true

class ApplicationPolicy
  attr_reader :user, :record

  def initialize(user, record)
    @user = user
    @record = record
  end

  def index?
    false
  end

  def show?
    scope.where(id: record.id).exists?
  end

  def create?
    false
  end

  def new?
    create?
  end

  def update?
    false
  end

  def edit?
    update?
  end

  def destroy?
    false
  end

  def scope
    Pundit.policy_scope!(user, record.class)
  end

  class Scope
    attr_reader :user, :scope

    def initialize(user, scope)
      @user = user
      @scope = scope
    end

    def resolve
      scope
    end

  end

  # `permit_admins_to` is a helper to easily allowing admins to perform actions.
  # Before, policies may have been written like this:
  # ```ruby
  # def show?
  #   user&.admin? || (record.published? && user&.not_banned?)
  # end
  # ```
  #
  # Now, the policy above can be written as:
  # ```ruby
  # permit_admins_to def show?
  #   record.published? && user&.not_banned?
  # end
  # ```
  # This allows users to `show?` if they're an admin,
  # or if the record is `published?` and the user is `not_banned?`.
  #
  # `user&.admin?` will always take precedence.
  def self.permit_admins_to(method_name)
    # To learn more about decorating methods, see Brandon's post:
    # https://dev.to/baweaver/decorating-ruby-part-1-symbol-method-decoration-4po2
    original_method = instance_method(method_name)

    define_method(method_name) do |*args, &block|
      user&.admin? || original_method.call(*args, &block)
    end
  end

end
