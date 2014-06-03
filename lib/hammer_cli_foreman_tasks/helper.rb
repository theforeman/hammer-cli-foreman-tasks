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
        load_task(id).fetch("external_id")
      rescue KeyError => e
        err = "Cannot find plan with task id #{id}"
        HammerCLI::Output::Output.new.print_error err
        logger.error err
       	return nil
      end
    end

    def compress(target, dest='.')
      archive = "#{dest}/#{target}.tar.gz"
      tgz = Zlib::GzipWriter.new(File.open(archive, 'wb'))
      Archive::Tar::Minitar.pack(target, tgz)
    end
  end
end
