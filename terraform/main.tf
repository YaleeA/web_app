# Specifying Docker provider
terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "3.0.2"
    }
  }
}

resource "docker_network" "app_network" {
  name = var.network_name
}

resource "docker_image" "local_image" {
  name         = "yaleea1996/web_app:${var.app_version}"
  keep_locally = false
}

resource "docker_container" "web_app" {
  count = length(var.web_app_names)  # Create multiple instances based on the names provided

  name  = var.web_app_names[count.index]  # Use the name from the list
  image = docker_image.local_image.name

  networks_advanced {
    name = docker_network.app_network.name
  }

  # Expose port for Flask app
  ports {
    internal = var.flask_port
  }

  healthcheck {
    test     = ["CMD", "curl", "-f", "http://localhost:${var.flask_port}"]
    interval = "30s"
    retries  = 3
    start_period = "10s"
    timeout  = "5s"
  }
}


resource "local_file" "nginx_conf" {
  filename = "${path.module}/nginx.conf"
  content  = templatefile("${path.module}/nginx.conf.tmpl", {
    web_app_names = var.web_app_names
  })
}

resource "docker_image" "nginx" {
  name         = "nginx:${var.nginx_version}"
  keep_locally = false
}


resource "docker_container" "nginx" {

  image = docker_image.nginx.name

  name  = "nginx_load_balancer"

    networks_advanced {
    name = docker_network.app_network.name
  }

  ports {
    internal = 8080
    external = var.nginx_port
  }

   volumes {
    host_path = abspath(local_file.nginx_conf.filename)
    container_path = "/etc/nginx/conf.d/nginx.conf"
  }

    healthcheck {
    test     = ["CMD", "curl", "-f", "http://localhost:8080"]
    interval = "30s"
    retries  = 3
    start_period = "10s"
    timeout  = "5s"
  }

}






