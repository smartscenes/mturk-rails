# == Schema Information
#
# Table name: mt_tasks
#
#  id                  :integer          not null, primary key
#  name                :string(255)
#  submitted_at        :datetime
#  completed_at        :datetime
#  title               :string(255)
#  description         :text
#  reward              :integer
#  num_assignments     :integer
#  max_workers         :integer
#  max_hits_per_worker :integer
#  keywords            :string(255)
#  shelf_life          :integer
#  max_task_time       :integer
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  user_id             :integer
#

class MtTask < ApplicationRecord
  # Internal Parameters
    attr_readonly   :name
    validates       :name, presence: true,
                           uniqueness: true,
                           length: { maximum: 80 }

  # Payment / Worker Parameters
    # note reward is an integer # of cents
    attr_accessible :num_assignments, :reward,
                    :max_workers, :max_hits_per_worker
    validates       :num_assignments, presence: true
    validates       :reward,          presence: true
    validates       :max_workers,     presence: true
    validates       :max_hits_per_worker, presence: true

  # Description Parameters (how the HIT appears publicly)
    # note keywords is a string: a comma separated list
    attr_accessible :title, :description, :keywords
    validates       :title,           presence: true, length: { maximum: 80 }
    validates       :description,     presence: true

  # Lifetime Parameters
    # The time at which HITs for this task were posted to mturk
    attr_accessible :submitted_at
    # after this time no more HITs could be completed on mturk
    # null until the HIT expires or all HITs completed
    attr_accessible :completed_at
    # number of seconds before the HITs in this task expire
    attr_readonly   :shelf_life
    validates       :shelf_life,      presence: true
    # max number of seconds for a worker to complete a task after accepting
    attr_readonly   :max_task_time
    validates       :max_task_time,   presence: true

  # MAKE SURE WE HAVE DEFAULTS
  before_validation :set_defaults


  validates :user_id, presence: true
  # belongs to sounds weird here, but that's the right
  # kind of association to form anyway.
  belongs_to :user, dependent: :destroy

  has_many :mt_hits, dependent: :destroy
  has_many :mt_assignments, through: :mt_hits

  # by default, present tasks in reverse chronological order
  default_scope{order('mt_tasks.created_at DESC')}

  # Status
  def submitted?
    !!self.submitted_at
  end

  def live?
    self.submitted? and not self.completed?
  end

  def completed?
    !!self.completed_at
  end

  # Modification Routines
  # expiration prevents any further assignments being created
  # but leaves approval/rejection decisions open
  def expire!
    mt_hits.each do |hit|
      hit_was_active = hit.live?
      hit.complete!
      begin
        RTurk::Hit.new(hit.mtId).expire! if hit_was_active
      rescue RTurk::InvalidRequest
        # log that we could not find this HIT
        logger.warn("Cannot expire unknown hit #{hit.mtId} for #{self.title}")
      end
    end
    self.completed_at = DateTime.now
    save!
  end

  # approves all outstanding assignments
  def approve!
    mt_hits.each do |hit|
      rhit = RTurk::Hit.new(hit.mtId)
      rhit.assignments.each do |assignment|
        begin
          assignment.approve! if assignment.status == 'Submitted'
        rescue RTurk::InvalidRequest
          # log that there was error approving the assignment
          logger.warn("Cannot approve assignment #{assignment.mtId} for hit #{hit.mtId} for #{self.title}")
        end
      end
    end
  end

  # completion closes out all the HITs, removes the HITs from the system,
  # and approves all outstanding assignments
  def complete!
    mt_hits.each do |hit|
      hit_was_active = hit.live?
      hit.complete!
      begin
        RTurk::Hit.new(hit.mtId).disable! if hit_was_active
      rescue RTurk::InvalidRequest
        # log that we could not find this HIT
        logger.warn("Cannot disable unknown hit #{hit.mtId} for #{self.title}")
      end
    end
    self.completed_at = DateTime.now
    save!
  end

  def self.create_task_and_user(params)
    name = params['name']

    # sanity check this request
    # some of these checks go beyond the record validation...
    raise 'no name provided for new task' unless name
    name = name.underscore
    task_controller = params['controller'] || name
    controller_path = Rails.root.join(
      'app', 'controllers', 'experiments',
      task_controller + '_controller.rb')
    unless controller_path.exist?
      raise ('Cannot create database entry for an experiment without ' +
             'a controller.  Could not find ' + controller_path.to_s)
    end

    # create a user for this task
    user = User.create! do |new_user|
      new_user.name = 'experiment_user_' + name
      new_user.provider = 'mturk'
    end

    task = user.create_mt_task! do |task|
      task.name                 = name
      task.title                = params['title']
      task.description          = params['description']
      task.reward               = params['reward']
      task.num_assignments      = params['num_assignments']
      task.max_workers          = params['max_workers']
      task.max_hits_per_worker  = params['max_hits_per_worker'] || 1
      task.keywords             = params['keywords']
      task.shelf_life           = params['shelf_life']
      task.max_task_time        = params['max_task_time']
      task.controller           = task_controller
    end
    
    # run a setup script
    setup_script_name = Rails.root.join('config', 'experiments',
                                        task_controller + '_setup.rb')
    require setup_script_name if File.exists?(setup_script_name)

    return [task, user]
  end


  def self.create_without_submitting(params)
    task, user = create_task_and_user(params)
    return task
  end

  def self.create_and_develop(params)
    task, user = create_task_and_user(params)
    task.develop!(params)
    return task
  end

  def self.update_and_submit(task, params)
    url  = params['url']
    raise "no url provided for new task" unless url

    task.update_config!(params)
    task.submit!(params)
    return task
  end

  def self.create_and_submit(params)
    url  = params['url']
    raise 'no url provided for new task' unless url

    task, user = create_task_and_user(params)
    task.submit!(params)
    return task
  end

  def update_config!(params)
    self.title                = params['title']
    self.description          = params['description']
    self.reward               = params['reward']
    self.num_assignments      = params['num_assignments']
    self.max_workers          = params['max_workers']
    self.max_hits_per_worker  = params['max_hits_per_worker'] || 1
    self.keywords             = params['keywords']
    self.shelf_life           = params['shelf_life']
    self.max_task_time        = params['max_task_time']
    self.controller           = params['controller'] || params['name']
    save!
  end

  def submit!(params)
    # for now, launch a single hit here
    num_HITs = self.max_hits_per_worker
    for i in 1..num_HITs
      hit_id = launch_hit(params)
      mt_hit = self.mt_hits.create! do |hit|
        hit.mtId = hit_id
        hit.conf = params
      end
    end

    # mark the task as submitted and save
    self.submitted_at = DateTime.now
    self.completed_at = nil
    save!
  end

  def develop!(params)
    # Setup the task for development
    # by adding a fake hit
    mt_hit = self.mt_hits.create! do |hit|
      hit.mtId = name
      hit.conf = params
    end
    save!
  end


  protected
    def set_defaults
      self.shelf_life ||= 259200 # 3 days
      self.max_task_time ||= 3600 # 1 hour
      self.max_hits_per_worker ||= 1
      self.max_workers ||= self.num_assignments
    end

    def launch_hit(params)
      task = self

      # dummy version of these params being set
      max_assignments = task.num_assignments

      rturk_hit = RTurk::Hit.create(:title => task.title) do |hit|
        hit.description   = task.description
        hit.reward        = task.reward / 100.0
        hit.assignments   = max_assignments
        hit.lifetime      = task.shelf_life
        hit.duration      = task.max_task_time
        hit.keywords      = task.keywords       if task.keywords
      
        task_url  = params['url']
        hit.question(task_url)

        qual = params['qualification']
        unless qual.nil?
          id = RTurk.sandbox? ? qual['sandbox_id'] : qual['id']
          hit.qualifications.add(id, :exists => true, :RequiredToPreview => true)
        end

        unless RTurk.sandbox? then
          #hit.qualifications.approval_rate gte: 95
          #hit.qualifications.hits_approved gte: 100
          hit.auto_approval = 259200 # 3 days
        end
      end

      return rturk_hit.id
    end
end
