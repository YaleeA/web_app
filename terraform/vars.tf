variable "app_version" {
  type    = string
  default = "1.0.0"
}

variable "network_name" {
  type    = string
  default = "app_network"
}

variable "nginx_version" {
  type    = string
  default = "latest"
}

variable "web_app_names" {
  type    = list(string)
  default = ["web_app_1", "web_app_2"]
}

variable "flask_port" {
  type    = number
  default = 5000
}

variable "nginx_port" {
  type    = number
  default = 8080
}

variable "nginx_conf_path" {
  type    = string
  default = "/home/yaleea/infinity_labs_train/skybox_ex/skybox_assignment/web_app/terraform/nginx.conf"  
}