require File.join(File.dirname(__FILE__), 'test_helper')

describe 'task' do
  let(:base_cmd) { %w[task] }
  let(:task) do
    {
      id: 1,
      humanized: {
        'action' => 'test_action',
        'input' => 'sample_input'
      },
      state: 'completed',
      result: 'success',
      started_at: '2023-10-31',
      ended_at: '2023-10-31',
      duration: '1h 30m',
      username: 'admin',
      errors: ['error1', 'error2']
    }
  end

  describe 'list' do
    let(:cmd) { base_cmd << 'list' }

    it 'should list all tasks' do
      api_expects(:foreman_tasks, :index, 'List').with_params(
        'page' => 1, 'per_page' => 1000
      ).returns(index_response([task]))

      output = IndexMatcher.new(
        [
          ['ID', 'ACTION', 'STATE', 'RESULT', 'STARTED AT', 'ENDED AT', 'DURATION', 'OWNER', 'TASK ERRORS'],
          ['1', '', 'completed', 'success', '2023-10-31', '2023-10-31', '1h 30m', 'admin', 'error1, error2']
        ]
      )
      expected_result = success_result(output)

      result = run_cmd(cmd)
      assert_cmd(expected_result, result)
    end
  end

  describe 'info' do
    let(:cmd) { base_cmd << 'info' }
    let(:params) { %w[--id=1] }

    it 'should show a task' do
      api_expects(:foreman_tasks, :show, 'Show').with_params('id' => '1').returns(task)

      expected_result = success_result(
        [
          "ID:         1",
          "Action:     test_action",
          "State:      completed",
          "Result:     success",
          "Started at: 2023/10/31 00:00:00",
          "Ended at:   2023/10/31 00:00:00",
          "Duration:   1h 30m",
          "Owner:      admin",
        ].join("\n")
      )

      result = run_cmd(cmd + params)
      assert_cmd(expected_result, result)
    end
  end

  describe 'resume' do
    let(:cmd) { base_cmd + ['resume'] }

    it 'should resume tasks paused in error state' do
      api_expects(:foreman_tasks, :bulk_resume, 'Bulk Resume').with_params({}).returns({
        total: 5,
        total_resumed: 3,
        total_failed: 1,
        total_skipped: 1,
        resumed: [task, task, task],
        failed: [task],
        skipped: [task]
      })

      result = run_cmd(cmd)
      assert_equal(70, result.exit_code)  # Check the exit code
    end
  end

  describe 'progress' do
    let(:cmd) { base_cmd + ['progress', '--option-id', '1'] }

    it 'should show the progress of the task' do
      api_expects(:foreman_tasks, :show, 'Show').with_params('id' => '1').returns(task)

      expected_result = success_result(
        [
          "ID:         1",
          "Action:     test_action",
          "State:      completed",
          "Result:     success",
          "Started at: 2023/10/31 00:00:00",
          "Ended at:   2023/10/31 00:00:00",
          "Duration:   1h 30m",
          "Owner:      admin",
        ].join("\n")
      )

      result = run_cmd(cmd)
      assert_cmd(expected_result, result)
    end
  end
end
