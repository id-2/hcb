# frozen_string_literal: true

module HasActivityLog
  extend ActiveSupport::Concern

  included do
    def audit_log(public_fields: [], include_comments: true, field_renames: {})
      history_entries = versions
      history_entries += comments if include_comments
      history_entries.sort_by(&:created_at).map do |v|
        result = {}
        result[:record] = v
        if v.instance_of?(::Comment)
          result[:type] = "comment"
        end
        if v.instance_of?(::PaperTrail::Version)
          result[:type] = v.event
          result[:created_at] = v.created_at
          result[:whodunnit] = v.whodunnit
          if public_fields.any?
            result[:extra_fields] = v.object_changes.as_json(only: public_fields)
          end
        end

        result
      end

    end
  end

end
