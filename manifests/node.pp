# Register Docker Node.
class rancher::node (
  $management,
  $registration_token,
  $agent_address = $::ipaddress,
  $docker_socket = '/var/run/docker.sock',
  $image_tag = 'latest',
  $rancher_master_port = 8080,
  $docker_env = []
) {
  validate_string($management)
  validate_string($registration_token)

  require docker

  docker::image { 'rancher/agent': } ->
  exec { 'bootstrap rancher agent':
    path      => ['/usr/local/bin', '/usr/bin', '/bin'],
    logoutput => true,
    command   => "docker run --privileged -v ${docker_socket}:/var/run/docker.sock -v /var/lib/rancher:/var/lib/rancher -e 'CATTLE_AGENT_IP=${agent_address}' rancher/agent:${image_tag} http://${management}:${rancher_master_port}/v1/scripts/${registration_token}",
    unless    => 'docker inspect rancher-agent',
  }
}
