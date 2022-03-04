variable "freenas_protocol" {
  type    = string
  default = "http"
}

variable "freenas_address" {
  type      = string
  sensitive = true
}

variable "freenas_username" {
  type      = string
  sensitive = true
}

variable "freenas_password" {
  type      = string
  sensitive = true
}

variable "freenas_http_port" {
  type    = string
  default = "80"
}

variable "freenas_iscsi_port" {
  type = string
}
