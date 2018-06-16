class CreateAssignmentsView < ActiveRecord::Migration[4.2]
  def up
    execute <<-SQL
      DROP VIEW IF EXISTS assignments_view;
    SQL
    execute <<-SQL
      CREATE VIEW assignments_view AS
        SELECT assignments.id,
               assignments.mtId AS assignmentId,
               assignments.data,
               assignments.created_at,
               assignments.updated_at,
               assignments.completed_at,
               assignments.status AS status,
               hits.mtId AS hitId,
               hits.conf AS conf,
               tasks.id AS taskId,
               tasks.controller AS taskController,
               tasks.name AS taskName,
               workers.mtId AS workerId
        FROM mt_assignments assignments
        JOIN mt_hits hits ON (hits.id = assignments.mt_hit_id)
        JOIN mt_tasks tasks ON (tasks.id = hits.mt_task_id)
        JOIN mt_workers workers ON (workers.id = assignments.mt_worker_id);
    SQL
  end

  def down
    execute <<-SQL
      DROP VIEW IF EXISTS assignments_view;
    SQL
  end
end
