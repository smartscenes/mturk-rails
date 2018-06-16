class CreateMtHits < ActiveRecord::Migration[4.2]
  def change
    create_table :mt_hits do |t|
      t.string :mtId
      t.integer :mt_task_id
      t.datetime :completed_at
      t.text :conf, limit: 65535

      t.timestamps
    end
    add_index :mt_hits, [:mtId]
    add_index :mt_hits, [:mt_task_id]
  end
end
