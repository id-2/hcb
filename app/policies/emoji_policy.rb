module EmojiPolicy
  extend ActiveSupport::Concern

  class_methods do
    # Helper for creating emoji methods for decorating policy methods.
    #
    # To learn more about decorating methods, see Brandon's post:
    # https://dev.to/baweaver/decorating-ruby-part-1-symbol-method-decoration-4po2
    def self.emoji(emoji_sym)
      emoji_shortcut = instance_method(emoji_sym)

      # Wrap the statically-defined emoji method (e.g. ⚡)
      define_method(emoji_sym) do |*method_names|
        method_names.flatten! # Handle case of chaining

        method_names.each do |method_name|
          # Get the original policy method (e.g. :show?)
          original_method = instance_method(method_name) rescue nil
          original_method = nil if original_method&.owner != self

          # Wrap the original policy method
          define_method(method_name) do
            # Evaluate the shortcut block in the content (binding) of the policy
            # class. Then, `or` it's result with the original method result.
            emoji_shortcut.bind_call(self) || original_method&.bind(self)&.call
          end
        end

        # Return the method name for chaining multiple emoji methods
        method_names
      end
    end

    # Admin
    emoji def ⚡
      user&.admin?
    end

    # Manager
    emoji def 🧑‍💼
      event = record.is_a?(Event) ? record : record.try(:event)
      event&.organizer_positions&.where(user: user, role: :manager)&.any?
    end

    # Organizer
    emoji def 👥
      event = record.is_a?(Event) ? record : record.try(:event)
      event&.organizer_positions&.where(user: user)&.any?
    end

    # Transparency Mode
    emoji def 🔎
      event = record.is_a?(Event) ? record : record.try(:event)
      event&.is_public?
    end

  end
end
