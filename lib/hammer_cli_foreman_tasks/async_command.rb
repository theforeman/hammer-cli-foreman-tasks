module HammerCLIForemanTasks

  module Async

    def self.included(base)
      base.send(:include, HammerCLIForemanTasks::Helper)
      base.send(:option, '--async', :flag, 'Do not wait for the task')
    end

    def execute
      if option_async?
        super
      else
        task_progress(send_request)
        HammerCLI::EX_OK
      end
    end

  end

  class AsyncCommand < HammerCLIForeman::Command
    include HammerCLIForemanTasks::Async

    build_options
  end
end
