require 'concerns/filterable'
require 'concerns/exportable'
class CompletedItemsView < ApplicationRecord
  include Filterable
  include Exportable
  self.table_name = 'completed_items_view'  # for rails >= 3.2
  self.primary_key = 'id'
  attr_readonly :data, :taskId, :taskName, :taskController, :workerId, :condition, :item, :status, :hitId, :assignmentId, :created_at, :updated_at
  dragonfly_accessor :preview

  belongs_to :mt_task, :foreign_key => 'taskId'
  default_scope{order('completed_items_view.created_at DESC')}

  def ok?
    status != 'REJ'
  end

  scope :workerId, lambda { |workerId| where(workerId: workerId) }
  scope :hitId, lambda { |hitId| where(hitId: hitId) }
  scope :assignmentId, lambda { |assignmentId| where(assignmentId: assignmentId) }
  scope :taskName, lambda { |taskName| where(taskName: taskName) }
  scope :taskId, lambda { |taskId| where(taskId: taskId) }
  scope :item, lambda { |item| where(item: item) }
  scope :status, lambda { |status| where(status: status) }
  scope :condition, lambda { |condition| where(condition: condition) }
  scope :ok, lambda { |ok|
             if ok
               where("status <> 'REJ' or status is null")
             else
               where(status: 'REJ')
             end
           }
  scope :hasStatus, lambda { |hasStatus|
    if hasStatus
      where("status is not null and status <> ''")
    else
      where("status is null or status = ''")
    end
  }
end
