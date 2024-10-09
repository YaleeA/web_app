provider "docker" {
  # Configure Docker Provider
}

# Create Docker network for ELK stack
resource "docker_network" "elk_network" {
  name   = var.network_name
  driver = "bridge"
}

# Define Docker volumes for Elasticsearch, Logstash, and Kibana
resource "docker_volume" "elasticsearch_volume" {
  name = "test_data"
}

resource "docker_volume" "logstash_volume" {
  name = "ls_data"
}

resource "docker_volume" "kibana_volume" {
  name = "kb_data"
}

# Elasticsearch container
resource "docker_container" "elasticsearch" {
  name  = "elasticsearch"
  image = var.elasticsearch_image

  ports {
    internal = 9200
    external = 9200
  }

  ports {
    internal = 9300
    external = 9300
  }

  volumes {
    host_path      = "./elk-config/elasticsearch/elasticsearch.yml"
    container_path = "/usr/share/elasticsearch/config/elasticsearch.yml"
  }

  volumes {
    volume_name    = docker_volume.elasticsearch_volume.name
    container_path = "/usr/share/elasticsearch/data"
  }

  networks_advanced {
    name = docker_network.elk_network.name
  }
}

# Logstash container
resource "docker_container" "logstash" {
  name  = "logstash"
  image = var.logstash_image

  ports {
    internal = 5044
    external = 5044
  }

  ports {
    internal = 9600
    external = 9600
  }

  volumes {
    host_path      = "./elk-config/logstash/logstash.conf"
    container_path = "/usr/share/logstash/pipeline/logstash.conf"
  }

  volumes {
    host_path      = "./elk-config/logstash/logstash.yml"
    container_path = "/usr/share/logstash/config/logstash.yml"
  }

  volumes {
    volume_name    = docker_volume.logstash_volume.name
    container_path = "/usr/share/logstash/data"
  }

  depends_on = [
    docker_container.elasticsearch
  ]

  networks_advanced {
    name = docker_network.elk_network.name
  }
}

# Kibana container
resource "docker_container" "kibana" {
  name  = "kibana"
  image = var.kibana_image

  ports {
    internal = 5601
    external = 5601
  }

  volumes {
    host_path      = "./elk-config/kibana/kibana.yml"
    container_path = "/usr/share/kibana/config/kibana.yml"
  }

  volumes {
    volume_name    = docker_volume.kibana_volume.name
    container_path = "/usr/share/kibana/data"
  }

  depends_on = [
    docker_container.elasticsearch
  ]

  networks_advanced {
    name = docker_network.elk_network.name
  }
}

# Filebeat container
resource "docker_container" "filebeat" {
  name  = "filebeat"
  image = var.filebeat_image
  restart = "unless-stopped"

  volumes {
    host_path      = "/var/lib/docker/containers"
    container_path = "/var/lib/docker/containers:ro"
  }

  volumes {
    host_path      = "./filebeat.yml"
    container_path = "/usr/share/filebeat/filebeat.yml"
  }

  depends_on = [
    docker_container.logstash
  ]

  networks_advanced {
    name = docker_network.elk_network.name
  }
}
