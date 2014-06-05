module HammerCLIForemanTasks
  class Exporter
    
    def initialize(logger, dynflow_binding)
      @logger = logger
      @dynflow_binding = dynflow_binding
      @output ||= HammerCLI::Output::Output.new
    end

    def export_plan(plan_id, path, with_action = false, compression = false)
      Dir.mktmpdir do |tmp|
        Dir.chdir(tmp)
        plan_js = dump_plan(plan_id)
        dump_plan_actions(plan_js) if with_action
        if compression
          compress(plan_id)
          FileUtils.cp("#{plan_id}.tar.gz", path)
        else
          FileUtils.mkdir_p(path) unless File.exists?(path)
          FileUtils.cp_r(plan_id, path)
        end
      end
    end
    
    def dump_plan(plan_id)
      FileUtils.mkdir_p(plan_id) unless File.exist?(plan_id)
      begin
        plan_js = @dynflow_binding.get_execution_plan(plan_id)
      rescue Exception => e
       log_error(e)
      end
      File.write("#{plan_id}/plan.json", plan_js)
      plan_js
    end

    def log_error(e)
      raise e if e.http_code.nil? || e.http_code != 404
      err = e.message + ":\n  " + e.response
      @output.print_error err
      @logger.error err
    end

    def dump_plan_actions(plan_js)
      plan = MultiJson.load(plan_js, :symbolize_keys => true)
      action_ids = plan[:steps].map { |step| step[:action_id] }.uniq
      action_ids.each { |action_id| self.dump_action(plan[:id], action_id, @dynflow_binding) }
    end

    def export_actions(plan_id, action_ids, path)
      Dir.mktmpdir do |tmp|
        Dir.chdir(tmp)
        FileUtils.mkdir(plan_id) unless Dir.exists?(plan_id)
        action_ids.each do |action_id|
          dump_action(plan_id, action_id)
        end
        FileUtils.mkdir_p(path) unless File.exists?(path)
        FileUtils.cp_r(plan_id, path)
      end
    end

    def dump_action(plan_id, action_id, dynflow_binding = @dynflow_binding)
      begin
        File.write("#{plan_id}/action-#{action_id}.json",
                   dynflow_binding.get_action(plan_id, action_id))
      rescue Exception => e
        File.exists?("#{plan_id}/action-#{action_id}.json") && File.delete("#{plan_id}/action-#{action_id}.json")
        log_error(e)
      end
    end

    def compress(target, dest='.')
      archive = "#{dest}/#{target}.tar.gz"
      tgz = Zlib::GzipWriter.new(File.open(archive, 'wb'))
      Archive::Tar::Minitar.pack(target, tgz)
    end
  end
end
