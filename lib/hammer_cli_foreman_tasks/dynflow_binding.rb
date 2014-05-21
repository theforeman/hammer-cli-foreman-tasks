module HammerCLIForemanTasks
	class DynflowBinding	
		def initialize
			foreman_settings = HammerCLI::Settings.get(:foreman)
			@resource = RestClient::Resource.new(
				foreman_settings.fetch(:host).gsub(/\/$/,'')+'/foreman_tasks/dynflow/api/',
				:user => foreman_settings.fetch(:username),
				:password => foreman_settings.fetch(:password))
		end
		
		def get_execution_plan(plan_id)
			@resource["#{plan_id}.json"].get
		end

		def get_action(plan_id, action_id)
			@resource["#{plan_id}/#{action_id}.json"].get
		end
  end
end
