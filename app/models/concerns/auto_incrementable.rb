# frozen_string_literal: true

module AutoIncrementable
  extend ActiveSupport::Concern
  included do
    # Acts as paranoid is required to maintain the max auto-incremented id after
    # a deletion.
    acts_as_paranoid

    # before_validation :set_auto_increment

    validates :expense_number, uniqueness: { scope: :reimbursement_report_id }, allow_nil: true

    before_create on: %i[create transfer] do
      scope_relation = self.class.where(self.as_json(only: %i[reimbursement_report_id]))
      new_number = scope_relation.maximum(:expense_number) + 1
      self.expense_number = new_number
    end

  end

  class_methods do
    # attr_accessor :auto_increment_config

    # def auto_increment(column, scope: nil)
    #   self.auto_increment_config = Config.new(column:, scope:)
    #
    #   # Add validations to model
    #   validation_config = {}
    #   validation_config[:uniqueness] = { scope: } if scope
    #   validates auto_increment_config.column, validation_config
    #
    #   # Set up callback
    #   callback_method_name = "set_auto_increment_#{auto_increment_config.column}"
    #   before_validation callback_method_name, on: %i[create transfer]
    #
    #   define_method callback_method_name do
    #     self.class.where(auto_increment_config.scope => self.send(auto_increment_config.scope)).maximum(auto_increment_config.column) + 1
    #
    #
    #   end
    # end
  end

  class Config
    attr_accessor :column, :scope

    def initialize(column:, scope:)
      @column = column
      @scope = scope
    end
  end

end
