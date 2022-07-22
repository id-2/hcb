# frozen_string_literal: true

module Api
  module Helpers
    class Version
      # This versioning system takes inspiration from Semantic Versioning 2.0.0
      # (https://semver.org/), but adds a new level called Dominant. This is
      # because our Hack Club Bank Transparency API will always be locked into
      # version 3 (v1 as a club api, v2 was for partners). If we were to use the
      # standard SemVer (with 3 levels), we would loose the ability to
      # communicate either breaking chances or patches. To compromise, our
      # versioning system adds another level above major.
      #
      # dominant.major.minor.patch
      #
      # We're ignoring the use of pre-release and builds as defined by SemVer.

      def initialize(version)
        @version = self.class.parse_version version
      end

      IDENTIFIERS = [:dominant, :major, :minor, :patch]

      IDENTIFIERS.each_with_index do |ident, index|
        define_method ident do
          @version[index] || 0
        end
      end

      def version
        @version
      end

      def version_levels
        Hash[IDENTIFIERS.zip @version]
      end

      def ==(other)
        @version == other.version
      end

      def !=(other)
        !self.== other
      end

      def <=>(other)
        @version <=> other.version
      end

      [:>, :>=, :<, :<=].each do |op|
        define_method op do |other|
          (self.version <=> other.version).public_send(op, 0)
        end
      end

      def to_s
        "v#{@version.join '.'}"
      end

      def self.parse_version(version)
        v = version.gsub('v', '').split('.').map &:to_i
        v.fill(0, v.length...IDENTIFIERS.length) # pad right with 0
      end

    end
  end
end