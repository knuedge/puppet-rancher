# Management Server.
class rancher::management(
  $rancher_manager_port     = '8080',
  $docker_cleanup_container = true,
  $docker_cleanup_volume    = false,
  $docker_image_tag         = false,
  $mysql_bind_mount         = false,
  $mysql_bind_mount_path    = '/usr/local/var/lib/mysql'
){
  require docker

  if $docker_image_tag {
    docker::image { 'rancher/server':
      image_tag => $docker_image_tag
    }
  }
  else {
    docker::image { 'rancher/server':
    }
  }

  $volumes = $mysql_bind_mount ? {
    true    => ["${mysql_bind_mount_path}:/var/lib/mysql"],
    default => []
  }

  docker::run { 'rancher/server':
    image                     => 'rancher/server',
    ports                     => ["${rancher_manager_port}:8080"],
    require                   => Docker::Image['rancher/server'],
    remove_container_on_start => $docker_cleanup_container,
    remove_volume_on_start    => $docker_cleanup_volume,
    remove_container_on_stop  => $docker_cleanup_container,
    remove_volume_on_stop     => $docker_cleanup_volume,
    volumes                   => $volumes
  }
}
