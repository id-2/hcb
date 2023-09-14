# frozen_string_literal: true

class AddCardGrantSurveys < ActiveRecord::Migration[7.0]
  def change
    add_column :card_grants, :post_grant_survey_answers, :jsonb
    add_column :events, :post_grant_survey_schema, :jsonb
  end

end
