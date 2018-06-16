class CreateMtTasks < ActiveRecord::Migration[4.2]
  def change
    create_table :mt_tasks do |t|
      t.string   :name
      t.datetime :submitted_at
      t.datetime :completed_at
      t.string   :title
      t.text     :description
      t.integer  :reward
      t.integer  :num_assignments
      t.integer  :max_workers
      t.integer  :max_hits_per_worker
      t.string   :keywords
      t.integer  :shelf_life
      t.integer  :max_task_time
      t.integer  :user_id
      t.string   :controller

      t.timestamps
    end

    add_index :mt_tasks, [:name]
    add_index :mt_tasks, [:controller]
    add_index :mt_tasks, [:created_at]
  end
end
