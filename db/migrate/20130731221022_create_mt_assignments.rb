class CreateMtAssignments < ActiveRecord::Migration[4.2]
  def change
    create_table :mt_assignments do |t|
      t.string :mtId
      t.integer :mt_hit_id
      t.integer :mt_worker_id
      t.text :data, limit: 16777215
      t.datetime :completed_at
      t.string :coupon_code
      t.string :status

      t.timestamps
    end
    add_index :mt_assignments, [:mtId, :mt_hit_id, :mt_worker_id]
    add_index :mt_assignments, [:completed_at]
    add_index :mt_assignments, [:created_at]
    add_index :mt_assignments, [:updated_at]
    add_index :mt_assignments, [:status]
  end
end

