module HammerCLIForemanTasks
  module Helper

    # render the progress of the task using polling to the task API
    def task_progress(task_or_id)
      task_id = task_or_id.is_a?(Hash) ? task_or_id['id'] : task_or_id
      TaskProgress.new(task_id) { |id| load_task(id) }.tap do |task_progress|
        task_progress.render
      end
    end

    def load_task(id)
      self.class.resource(:foreman_tasks).call(:show, :id => id)
    end

    def task_to_plan_id(id)
      begin
        load_task(id)["input"]["label"]["execution_plan_id"]
      rescue
        raise "No task with id '#{id}'"
      end
    end
  end
end
