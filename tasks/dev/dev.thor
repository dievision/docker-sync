load "#{File.dirname(File.dirname(__FILE__))}/stack/stack.thor"

class Dev < Stack
  # This is just an extra wrapper on docker-sync-stack-start that will eventually call start()
  desc 'up', 'finishes all copies and start container stack'
  def up
    config = DockerSync::ProjectConfig.new(config_path: options[:config])
    config['syncs'].each do |name, actions|
      perform_copy(actions) if actions.has_key?("extra_commands")
    end

    start # from docker-sync-stack start
  end

  desc 'down', 'stops all running containers'
  def down
    command = 'docker stop $(docker ps -q)'
    say_status 'stopping', command, :red
  end

  desc 'start', 'restart one specific container'
  def restart(*args)
    $stderr.puts "__________________#{options.inspect}"
    $stderr.puts "__________________#{args.inspect}"
    args.each do |container|
      container_id = `docker ps -a --filter "name=_#{container}" --last 1 -q`

      $stderr.puts "__________________#{`docker inspect --format='{{.LogPath}}' #{container_id}`}"
    end
    # sudo sh -c "echo \"\" > $(docker inspect --format='{{.LogPath}}' $(docker ps -a --filter "name=_$1" --last 1 -q))"
    # docker-compose restart $1
  end

  private

  def perform_copy(actions)
    [actions['extra_commands']].flatten.each do |command|
      say_status 'executing', command, :blue
      `#{command}`
    end
  end

end
