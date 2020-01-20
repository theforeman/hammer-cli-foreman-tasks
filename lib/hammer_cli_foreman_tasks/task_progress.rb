require 'powerbar'
module HammerCLIForemanTasks
  class TaskProgress
    attr_accessor :interval, :task

    def initialize(task_id, options = {}, &block)
      @update_block = block
      @task_id      = task_id
      @interval     = 2
      @options      = options
    end

    def render
      update_task
      render_progress
    end

    def success?
      !%w(error warning).include?(@task['result'])
    end

    private

    def render_progress
      progress_bar do |bar|
        begin
          while true
            bar.show(:msg => progress_message, :done => @task['progress'].to_f, :total => 1)
            if task_pending?
              sleep interval
              update_task
            else
              break
            end
          end
        rescue Interrupt
          # Inerrupting just means we stop rednering the progress bar
        end
      end
    end

    def progress_message
      "Task #{@task_id} #{task_pending? ? @task['state'] : @task['result']}"
    end

    def render_result
      puts @task['humanized']['output'] if !@task['humanized']['output'].to_s.empty? && appropriate_verbosity?
      unless @task['humanized']['errors'].nil? || @task['humanized']['errors'].empty?
        STDERR.puts "Error: #{@task['humanized']['errors'].join("\n")}"
      end
    end

    def update_task
      @task = @update_block.call(@task_id)
    end

    def task_pending?
      !%w[paused stopped].include?(@task['state'])
    end

    def progress_bar
      bar                                      = PowerBar.new
      @closed = false
      bar.settings.tty.finite.template.main    = '[${<bar>}] [${<percent>%}]'
      bar.settings.tty.finite.template.padchar = ' '
      bar.settings.tty.finite.template.barchar = '.'
      bar.settings.tty.finite.output           = Proc.new { |s| $stderr.print s if appropriate_verbosity? }
      yield bar
    ensure
      bar.close
      render_result
    end

    def appropriate_verbosity?
      @options[:verbosity] >= HammerCLI::V_VERBOSE
    end
  end
end
