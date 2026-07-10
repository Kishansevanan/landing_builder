class CreatePages < ActiveRecord::Migration[8.1]
  def change
    create_table :pages do |t|
      t.references :user, null: false, foreign_key: true
      t.string   :title,  null: false
      t.string   :slug,   null: false
      t.integer  :status, null: false, default: 0
      t.jsonb    :layout, null: false, default: { elements: [] }
      t.datetime :published_at

      t.timestamps
    end
    add_index :pages, :slug, unique: true
  end
end
