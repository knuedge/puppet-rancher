# Management Server.
class rancher::management(
  $rancher_manager_port     = '8080',
  $docker_cleanup_container = true,
  $docker_cleanup_volume    = false,
  $docker_image_tag         = false,
  $database_host            = undef,
  $database_port            = 3306,
  $database_username        = 'cattle',
  $database_password        = 'cattle',
  $database_name            = 'cattle',
  $mysql_bind_mount         = false,
  $mysql_bind_mount_path    = '/usr/local/var/lib/mysql'
){
  require docker

  if ($database_host != undef) {
    $env = [
      "CATTLE_DB_CATTLE_MYSQL_HOST=${database_host}",
      "CATTLE_DB_CATTLE_MYSQL_PORT=${database_port}",
      "CATTLE_DB_CATTLE_MYSQL_NAME=${database_name}",
      "CATTLE_DB_CATTLE_USERNAME=${database_username}",
      "CATTLE_DB_CATTLE_PASSWORD=${database_password}",
    ]
  } else {
    $env = []
  }

  if $docker_image_tag {
    docker::image { 'rancher/server':
      image_tag => $docker_image_tag
    }
  }
  else {
    docker::image { 'rancher/server':
    }
  }

  $image_name = $docker_image_tag ? {
    /[a-zA-Z0-9]+/ => "rancher/server:${docker_image_tag}",
    default => 'rancher/server'
  }

  $volumes = $mysql_bind_mount ? {
    true    => ["${mysql_bind_mount_path}:/var/lib/mysql"],
    default => []
  }

  docker::run { 'rancher/server':
    image                     => $image_name,
    ports                     => ["${rancher_manager_port}:8080"],
    env                       => $env,
    require                   => Docker::Image['rancher/server'],
    remove_container_on_start => $docker_cleanup_container,
    remove_volume_on_start    => $docker_cleanup_volume,
    remove_container_on_stop  => $docker_cleanup_container,
    remove_volume_on_stop     => $docker_cleanup_volume,
    volumes                   => $volumes
  }
}
