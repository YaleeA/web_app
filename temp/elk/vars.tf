variable "elasticsearch_image" {
  default = "elasticsearch:7.9.1"
}

variable "logstash_image" {
  default = "logstash:7.9.1"
}

variable "kibana_image" {
  default = "kibana:7.9.1"
}

variable "filebeat_image" {
  default = "docker.elastic.co/beats/filebeat:7.9.1"
}

variable "network_name" {
  default = "elk"
}

variable "elasticsearch_ports" {
  default = ["9200:9200", "9300:9300"]
}

variable "logstash_ports" {
  default = ["5044:5044", "9600:9600"]
}

variable "kibana_ports" {
  default = ["5601:5601"]
}

variable "elasticsearch_volumes" {
  default = [
    "test_data:/usr/share/elasticsearch/data/",
    "./elk-config/elasticsearch/elasticsearch.yml:/usr/share/elasticsearch/config/elasticsearch.yml"
  ]
}

variable "logstash_volumes" {
  default = [
    "./elk-config/logstash/logstash.conf:/usr/share/logstash/pipeline/logstash.conf",
    "./elk-config/logstash/logstash.yml:/usr/share/logstash/config/logstash.yml",
    "ls_data:/usr/share/logstash/data"
  ]
}

variable "kibana_volumes" {
  default = [
    "./elk-config/kibana/kibana.yml:/usr/share/kibana/config/kibana.yml",
    "kb_data:/usr/share/kibana/data"
  ]
}

variable "filebeat_volumes" {
  default = [
    "/var/lib/docker/containers:/var/lib/docker/containers:ro",
    "./filebeat.yml:/usr/share/filebeat/filebeat.yml"
  ]
}
