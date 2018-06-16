class CreateMtCompletedItems < ActiveRecord::Migration[4.2]
  def change
    create_table :mt_completed_items do |t|
      t.references :mt_task, index: true
      t.references :mt_worker, index: true
      t.integer :mt_hit_id
      t.integer :mt_assignment_id
      t.string :mt_condition
      t.string :mt_item
      t.text :data, limit: 16777215
      t.string :status
      t.string :preview_uid
      t.string :preview_name
      t.string :code

      t.timestamps
    end
    add_index :mt_completed_items, :created_at
    add_index :mt_completed_items, :updated_at
    add_index :mt_completed_items, :mt_assignment_id
    add_index :mt_completed_items, :mt_hit_id
    add_index :mt_completed_items, :mt_condition
    add_index :mt_completed_items, :mt_item
    add_index :mt_completed_items, :status
  end
end
