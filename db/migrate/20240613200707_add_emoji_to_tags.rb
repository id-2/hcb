class AddEmojiToTags < ActiveRecord::Migration[7.1]
  def change
    add_column :tags, :emoji, :string
  end
end
