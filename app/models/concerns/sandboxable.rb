# frozen_string_literal: true

module Sandboxable
  extend ActiveSupport::Concern

  # There are two "model environments":
  #   - live
  #   - sandbox
  # These environments are implemented via Rails STI (Single Table Inheritance).
  # To add model environments to a model, do the following:
  #   1. Create a migration to add a `string` column named `type` to the model.
  #   2. Add `include Sandboxable` to the base model (e.g. `User`).
  #   3. Create files for the two new subclasses of the model:
  #      - `<model_name>Live`. (e.g. `UserLive`)
  #      - `<model_name>Sandbox`. (e.g. `UserSandbox`)
  #   4. Update the `type` column of existing model objects (table rows) to use
  #      one of the new subclasses. They most like should become `Live` objects.
  #      Make sure to be careful and accurate with this since Rails will throw
  #      invalid subclass errors if the value in the `type` column does not
  #      match one of the subclasses.
  #      (e.g. `User.update_all(type: 'UserLive')`)
  #
  #      Note: This could (and maybe should) be done as a part of the migration
  #      in step 1.

  LIVE_CLASS_SUFFIX = 'Live'
  SANDBOX_CLASS_SUFFIX = 'Sandbox'

  included do
    def live_mode?
      self.class.name.ends_with?(LIVE_CLASS_SUFFIX)
    end

    def sandbox_mode?
      self.class.name.ends_with?(SANDBOX_CLASS_SUFFIX)
    end

    scope :live_mode, -> { where("type LIKE '%#{LIVE_CLASS_SUFFIX}'") }
    scope :sandbox_mode, -> { where("type LIKE '%#{SANDBOX_CLASS_SUFFIX}'") }
  end

  # Extend RecordNotFound to make it easier to rescue
  class RecordInOtherModelEnvironment < ActiveRecord::RecordNotFound; end

  module ClassMethods

    def find_with_hint_env(*args)
      find(*args)

    rescue ActiveRecord::RecordNotFound => e
      # Determine if this is a base class (or a subclass).
      # Example:
      #     Partner is a base class (superclass)
      #     PartnerLive and PartnerSandbox are both subclasses of Partner

      # If this is a base class, then we can't find the record.
      super_class = self.superclass
      raise e if super_class == ApplicationRecord

      # Since this is a subclass, we will try to find the record in the base
      # class. This assumes that there is only ONE level of inheritance.
      begin
        object = super_class.find(*args)

        # The record was found in the base class. Raise a more useful error
        # message.

        # Attempt to determine which environment the record was found in.
        class_name = object.class.name
        raise e if class_name.nil?

        env = if class_name.end_with?(LIVE_CLASS_SUFFIX)
                LIVE_CLASS_SUFFIX
              elsif class_name.end_with?(SANDBOX_CLASS_SUFFIX)
                SANDBOX_CLASS_SUFFIX
              end

        err_msg_amendment =
          if env.present?
            "However, the record was found in the #{env} model environment."
          else
            "However, the record was found as a #{class_name}."
          end

      rescue
        # The record was not found in the base class. Raise the original error.
        raise e
      end

      raise RecordInOtherModelEnvironment, e.message + ". " + err_msg_amendment

    end
  end
end
