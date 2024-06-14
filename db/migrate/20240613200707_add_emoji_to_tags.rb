class AddEmojiToTags < ActiveRecord::Migration[7.1]
  def change
    add_column :tags, :emoji, :string
    add_column :tags, :color, :string
  end
end
