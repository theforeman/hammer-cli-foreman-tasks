module HammerCLIForemanTasks
  module Helper
    # render the progress of the task using polling to the task API
    def task_progress(task_or_id)
      task_id = task_or_id.is_a?(Hash) ? task_or_id['id'] : task_or_id
      if !task_id.empty?
        options = { verbosity: @context[:verbosity] || HammerCLI::V_VERBOSE, adapter: (@context[:adapter] || :base).to_s }
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
