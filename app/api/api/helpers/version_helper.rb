# frozen_string_literal: true

module Api
  module Helpers
    module VersionHelper
      def self.included(base)
        base.extend ClassMethods
      end

      module ClassMethods
        def version_is?(operator = :==, version)
          proc do |object, options|
            opt_ver = Version.new(options[:version])
            arg_ver = version.is_a?(Version) ? version : Version.new(version.to_s)
            opt_ver.public_send(operator, arg_ver)
          end
        end

        def for_version(operator = :==, version, &block)
          with_options(if: version_is?(operator, version), &block)
        end

        # inclusive
        def for_version_between(lowerVersion, upperVersion, &block)
          with_options(if: proc do |object, options|
            version_is?(:>=, lowerVersion).call(object, options) &&
              version_is?(:<=, upperVersion).call(object, options)
          end, &block)
        end

      end
    end
  end
end