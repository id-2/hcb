# frozen_string_literal: true

module Api
  class Base < Grape::API
    VERSIONS = %w(v3 v3.1.0.0)

    VERSIONS.each do |v|
      version v, using: :path do
        mount Api::V3
      end
    end
  end
end
