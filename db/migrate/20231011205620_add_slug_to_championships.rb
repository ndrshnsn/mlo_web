class AddSlugToChampionships < ActiveRecord::Migration[7.1]
  def change
    add_column :championships, :slug, :string
  end
end
