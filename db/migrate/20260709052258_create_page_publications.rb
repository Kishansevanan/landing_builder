class CreatePagePublications < ActiveRecord::Migration[8.1]
  def change
    create_table :page_publications do |t|
      t.references :page, null: false, foreign_key: true
      t.text :html, null: false
      t.text :css,  null: false

      t.timestamps
    end
  end
end
