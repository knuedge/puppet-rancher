# Register Docker Node.
class rancher::node (
  $management,
  $registration_token,
  $rancher_master_port = 8080,
  $docker_env = []
) {
  validate_string($management)
  validate_string($registration_token)

  require docker

  docker::image { 'rancher/agent':
  }

  docker::run { 'rancher/node':
    image      => 'rancher/agent',
    restart    => 'no',
    privileged => true,
    command    => "http://${management}:${rancher_master_port}/v1/scripts/${registration_token}",
    volumes    => [
      '/var/run/docker.sock:/var/run/docker.sock',
      '/var/lib/rancher:/var/lib/rancher'
    ],
    require    => Docker::Image['rancher/agent'],
    env        => $docker_env
  }
}
