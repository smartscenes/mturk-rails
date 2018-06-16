class Experiments::<%= class_name %>Controller < ApplicationController
  require 'action_view'

  include ActionView::Helpers::DateHelper
  include MturkHelper
  include Experiments::ExperimentsHelper

  before_filter :load_new_tab_params, only: [:index]
  before_filter :load_data_generic, only: [:index]
  before_filter :estimate_task_time, only: [:index]

  before_filter :can_view_tasks_filter, only: [:results, :view]
  before_filter :retrieve_list, only: [:results]
  before_filter :retrieve_item, only: [:view, :load]

  layout 'basic', only: [:index]

  def index
      if @entries.any? then
        render "experiments/<%= file_name %>/index", layout: true
      else
        @message = @no_entries_message
        render "mturk/message", layout: false
      end
  end

  def results
    render "experiments/<%= file_name %>/results", layout: true
  end

  def retrieve_list
    @task_name = params['task'] || params['taskName'] || controller_name
    @task = MtTask.find_by_name!(@task_name)
    @completed = get_completed_items(@task.id)
  end

end
