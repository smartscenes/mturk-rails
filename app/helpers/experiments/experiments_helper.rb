module Experiments::ExperimentsHelper
  require 'csv'
  require 'set'

  def load_data_generic
    load_data(method(:load_generic_entries))
  end

  def load_data_generic_tsv
    # Loads data from a generic (headers can be anything) tsv file
    load_data(method(:load_generic_entries_tsv))
  end

  def load_data_generic_csv
    load_data(method(:load_generic_entries_csv))
  end

  def load_conf
    if @task == nil
      @task = MtTask.find_by_name!("#{controller_name}")
    end
    @conf = YAML.load_file("config/experiments/#{@task.name}.yml")['conf']
    @title = @task.title
  end

  def load_data(load_entries_func = method(:load_generic_entries), filter_entries_func = NIL)
    # Populates @entries based on config file, including choosing random entries to show to turker
    load_conf
    if @conf.key?('inputFile')
      # Get entries from file
      @entries = load_and_select_random_file(@conf['inputFile'], @conf['doneFile'],
                                             @conf['doneThreshold'], @conf['perWorkerItemCompletedThreshold'],
                                             @conf['selectPolicy'], @conf['selectCondition'], @conf['nItems'],
                                             load_entries_func, filter_entries_func)
    elsif @conf.key?('inputTable')
      # Get entries from db
      @entries = load_and_select_random_table(@conf['inputTable'], @conf['inputFilters'],  @conf['doneFile'],
                                              @conf['doneThreshold'], @conf['perWorkerItemCompletedThreshold'],
                                              @conf['selectPolicy'], @conf['selectCondition'], @conf['nItems'],
                                              filter_entries_func)
    elsif @conf.key?('inputTask')
      # Get entries from db
      @entries = load_and_select_random_task(@conf['inputTask'], @conf['inputFilters'], @conf['doneFile'],
                                             @conf['doneThreshold'], @conf['perWorkerItemCompletedThreshold'],
                                             @conf['selectPolicy'], @conf['selectCondition'], @conf['nItems'],
                                             filter_entries_func)
    else
      logger.error('Please specify either inputFile or inputTask in the configuration file for your task')
    end
    @no_entries_message = 'You already completed all items in this task!  There are no more items for you to complete.'
  end

  def estimate_task_time
    itemTimeInSecs = @conf['itemEditSecs']
    taskTimeInSecs = @conf['itemEditSecs']*@conf['nItems']
    @taskTime = {
      'itemTimeInSecs' => itemTimeInSecs,
      'itemTime' => distance_of_time_in_words(itemTimeInSecs),
      'taskTimeInSecs'  => taskTimeInSecs,
      'taskTime'  => distance_of_time_in_words(taskTimeInSecs)
    }
  end

  # Select entries from db table instead of input file
  def load_and_select_random_table( inputTable, filters, doneFile, doneThreshold,
                                    itemCompletedThreshold, select_policy, select_condition, n,
                                    filter_entries_func)
    # Load entries from DB
    inputModel = inputTable.classify.constantize
    filters = filters || { :hasStatus => false }
    all_entries = inputModel.filter(filters)

    #all_entries = all_entries.to_hash #ActiveRecord (4.2.4+)
    all_entries = all_entries.to_a.map(&:serializable_hash)

    select_random_entries(all_entries, doneFile, doneThreshold, itemCompletedThreshold, select_policy, select_condition, n,
                          filter_entries_func)
  end

  # Select entries from mt_completed_items_ instead of input file
  def load_and_select_random_task( inputTask, filters, doneFile, doneThreshold,
                                   itemCompletedThreshold, select_policy, select_condition, n,
                                   filter_entries_func)
    # Load entries from DB
    filters = filters || { :hasStatus => false }
    filters[:taskName] = inputTask
    all_entries = CompletedItemsView.filter(filters)

    #all_entries = all_entries.to_hash #ActiveRecord (4.2.4+)
    all_entries = all_entries.to_a.map(&:serializable_hash)

    select_random_entries(all_entries, doneFile, doneThreshold, itemCompletedThreshold, select_policy, select_condition, n,
                          filter_entries_func)
  end

  # Select entries from a data file
  def load_and_select_random_file(inputFile, doneFile, doneThreshold, itemCompletedThreshold, select_policy, select_condition, n,
                                  load_entries_func = method(:load_generic_entries), filter_entries_func)
    # Load entries from file
    all_entries = load_entries_func.call(inputFile)
    select_random_entries(all_entries, doneFile, doneThreshold, itemCompletedThreshold, select_policy, select_condition, n,
                          filter_entries_func)
  end

  def select_random_entries(all_entries, doneFile, doneThreshold,
                            itemCompletedThreshold, select_policy, select_condition, n,
                            filter_entries_func)
    # Figure out task and worker id
    taskId = @task.id
    workerId = @worker ? @worker.mtId : ''
    # filter entries by filterCallback
    if filter_entries_func
      all_entries = filter_entries_func.call(all_entries)
    end
    logger.info('selecting ' + n.to_s + ' from ' + all_entries.size.to_s)
    entries = filter_done_entries(all_entries, taskId, doneFile, doneThreshold, select_condition)
    select_entries_for_worker(entries, taskId, workerId, itemCompletedThreshold, select_policy, select_condition, n)
  end

  def filter_done_entries(all_entries, taskId, doneFile, doneThreshold, select_condition)
    # Filter all entries by entries that were deemed overall "DONE"
    if doneFile != nil && doneFile != ''
      # Use file to figure out what items are done
      if doneThreshold != nil && doneThreshold > 0
        # Load done entries from file
        done_entries = load_entries_done(doneFile)
        # Only consider those items with a count greater than the threshold to be done
        all_done_count = done_entries.size
        done_entries = done_entries.select{ |x| x[:count].to_i >= doneThreshold }
        done_count = done_entries.size
        logger.debug "Identified done #{done_count} of #{all_done_count} (threshold #{doneThreshold})"
        # Remove done from all
        done = done_entries.map{ |x| x[:id] }.to_set
        entries = all_entries.select{ |x| !done.include?(x['id']) }
      else
        entries = all_entries
      end
    else
      if doneThreshold != nil && doneThreshold > 0
        # Figure out count of done items from database
        # done_entries is a hash of item id to count
        done_entries = count_completed_entries(taskId, select_condition)

        # Only consider those items with a count greater than the threshold to be done
        all_done_count = done_entries.size
        done_entries = done_entries.select{ |k,v| v.to_i >= doneThreshold }
        done_count = done_entries.size
        logger.debug "Identified done #{done_count} of #{all_done_count} (threshold #{doneThreshold})"
        done = done_entries.map{ |k,v| k }.to_set

        # Remove done from all
        entries = all_entries.select{ |x| !done.include?(x['id']) }
      else
        entries = all_entries
      end
    end
    entries
  end

  def select_entries_for_worker(entries, taskId, workerId, itemCompletedThreshold, select_policy, select_condition, n)
    # Filter by entries that were already done for the worker
    if itemCompletedThreshold != nil && itemCompletedThreshold > 0
      entries = filter_worker_completed_entries(entries, taskId, workerId, itemCompletedThreshold)
    end

    # Experimental code for different selection policies
    logger.info "Selecting #{n} entries from #{entries.size} entries using policy #{select_policy}"
    match = /^(.*)_([0-9]+)/.match(select_policy)
    if match
      select_policy = match[1]
      select_policy_param = match[2].to_i
    end
    if select_policy == "random" || select_policy == nil
      # Do random selection from final remaining entries
      selected = select_random(entries, n)
    elsif select_policy == "mincount"
      # Select entries that were completed least
      entries_counts = count_completed_entries_for(taskId, select_condition, entries)
      selected = select_by_count_min(entries_counts, n)
    elsif select_policy == "mincount_random"
      # Select entries randomly, favoring those with minimum completed count
      entries_counts = count_completed_entries_for(taskId, select_condition, entries)
      selected = select_random_grouped(entries_counts, n, select_policy_param || 1)
    else
      raise "Invalid selection policy #{select_policy}"
    end
    logger.info("Selected is #{selected}")
    selected
  end

  def filter_worker_completed_entries(entries, taskId, workerId, itemCompletedThreshold)
    worker_completed_counts = count_worker_completed_entries(taskId, workerId)
    worker_completed = worker_completed_counts.select{ |k,v| v.to_i >= itemCompletedThreshold }
    logger.debug "Worker #{workerId} has already completed #{worker_completed_counts.size} entries, #{worker_completed.size} >= #{itemCompletedThreshold}"
    worker_done = worker_completed.map{ |k,v| k }.to_set
    entries.select{ |x| !worker_done.include?(x['id']) }
  end

  def load_worker_completed_entries(taskId, workerId)
    # Load entries that were already done by the worker for this task
    # We only count items that are not rejected (status != 'REJ')
    CompletedItemsView.where("taskId = ? AND workerId = ? AND #{check_status}", taskId, workerId)
  end

  def count_worker_completed_entries(taskId, workerId)
    # Count entries that were already done by the worker for this task
    # We only count items that are not rejected (status != 'REJ')
    CompletedItemsView.group(:item).where("taskId = ? AND workerId = ? AND #{check_status}", taskId, workerId).count()
  end

  def load_completed_entries(taskId)
    # Load entries that were already done for this task
    # We only count items that are not rejected (status != 'REJ')
    CompletedItemsView.where("taskId = ? AND #{check_status}", taskId)
  end

  def count_completed_entries(taskId, condition)
    # Count entries already done for this task
    # We only count items that are not rejected (status != 'REJ')
    if condition == 'all' || condition == nil then
      CompletedItemsView.group(:item).where("taskId = ? AND #{check_status}", taskId).count()
    else
      CompletedItemsView.group(:item).where("taskId = ? AND `condition` = ? AND #{check_status}", taskId, condition).count()
    end
  end

  def count_completed_entries_for(taskId, condition, entries)
    completed_counts = count_completed_entries(taskId, condition)
    entries.each { |x| x[:count] = completed_counts[x[:id]]? completed_counts[x[:id]]:0 }
  end


  def load_generic_entries(file)
    ext = File.extname(file)
    logger.info(ext)
    if ext == '.csv' then
      load_generic_entries_csv(file)
    elsif ext == '.tsv' then
      load_generic_entries_tsv(file)
    else
      raise "Unsupported file extension: #{ext}"
    end
  end

  def load_generic_entries_dsv(file, delimiter)
    # Loads entries from file
    csv_file = File.join(Rails.root,file)
    csv = CSV.read(csv_file, { :headers => true, :col_sep => delimiter, :skip_blanks => true})
    csv.map{ |row|
      map = {}
      row.each{ |pair|
        map[pair.first] = pair.second
      }
      map
    }
  end

  def load_generic_entries_tsv(file)
    load_generic_entries_dsv(file, "\t")
  end

  def load_generic_entries_csv(file)
    load_generic_entries_dsv(file, ",")
  end

  def load_entries_done(file)
    # Loads entry ids from file
    csv_file = File.join(Rails.root,file)
    csv = CSV.read(csv_file, :headers => false)
    csv.map { |row|
      {
          id: row[0],
          count: row[1]
      }
    }
  end

  def select_random(entries, n)
    if entries.length > n
      entries.shuffle.take(n)
    else
      entries.shuffle
    end
  end

  def select_random_grouped(entries, n, factor=1)
    if entries.length > n
      #logger.debug(entries)
      grouped = entries.group_by{ |x| x[:count] }
      #logger.debug(grouped)
      logger.info("Select random grouped n=#{n}, factor=#{factor}, entries=#{entries.length}")
      if factor > 1
        total = [factor*n, entries.length].min
        grouped.sort_by{ |k,v| k }.map{ |k,v| v.shuffle }.flatten.take(total).shuffle.take(n)
      else
        grouped.sort_by{ |k,v| k }.map{ |k,v| v.shuffle }.flatten.take(n)
      end
    else
      entries.shuffle
    end
  end

  def select_by_count_min(entries, n)
    if (entries.length > n)
      sorted = entries.sort_by{ |x| x[:count] }
      sorted.take(n).shuffle
    else
      entries.keys.shuffle
    end
  end

  def get_completed_items(taskId)
    filter = params.slice(:workerId, :item, :condition, :status, :hitId, :assignmentId, :ok, :hasStatus)
    if filter[:ok]
      filter[:ok] = filter[:ok].to_bool
    end
    if filter[:hasStatus]
      filter[:hasStatus] = filter[:hasStatus].to_bool
    end
    @completed = CompletedItemsView.where('taskId = ?', taskId).filter(filter)
    @completed
  end

  def retrieve_item
    @item = CompletedItemsView.find(params[:id])
    @data = JSON.parse(@item.data)
    @entry = @data['entry']
    @title = @item.taskName + ' ' + @item.condition + ' ' + @item.item
    @on_close_url = url_for(:action => 'results', :only_path => true)
  end

  private
    # We only count items that are not rejected (status != 'REJ')
    # TODO: Make this more efficient
    def check_status
      "(status <> 'REJ' or status is null)"
    end
end
