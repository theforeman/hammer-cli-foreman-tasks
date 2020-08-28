module HammerCLIForemanTasks
  module Helper
    # render the progress of the task using polling to the task API
    def task_progress(task_or_id)
      task_id = case task_or_id
      when Hash
        task_or_id['id']
      when Array
        Hash[*task_or_id.flatten(1)]['task_id']
      else
        task_or_id
      end
      if !task_id.empty?
        options = { verbosity: @context[:verbosity] || HammerCLI::V_VERBOSE }
        task_progress = TaskProgress.new(task_id, options) { |id| load_task(id) }
        task_progress.render
        task_progress.success?
      else
        signal_usage_error(_('Please mention appropriate attribute value'))
      end
    end

    def load_task(id)
      HammerCLIForeman.foreman_resource!(:foreman_tasks).call(:show, :id => id)
    end
  end
end
