module HammerCLIForemanTasks
  class AsyncCommand < HammerCLIForeman::Command
    include HammerCLIForemanTasks::Helper

    option '--async', :flag, 'Do not wait for the task'

    def execute
      if option_async?
        super
      else
        task_progress(send_request)
        HammerCLI::EX_OK
      end
    end

    apipie_options
  end
end
