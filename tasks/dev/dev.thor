load "#{File.dirname(File.dirname(__FILE__))}/stack/stack.thor"

class Dev < Stack
  # This is just an extra wrapper on docker-sync-stack-start that will eventually call start()
  desc 'up', 'finishes all copies and start container stack'
  def up
    config = DockerSync::ProjectConfig.new(config_path: options[:config])
    config['syncs'].each do |name, actions|
      perform_copy(actions) if actions.has_key?("extra_commands")
    end

    # start # from docker-sync-stack start
  end

  private

  def perform_copy(actions)
    [actions['extra_commands']].flatten.each do |command|
      say_status 'executing', command, :blue
      `#{command}`
    end
  end

end
