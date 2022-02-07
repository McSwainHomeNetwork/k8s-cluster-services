variable "k8s_host" {
  type        = string
  default     = ""
  description = "Address of the k8s host."
  sensitive   = true
}

variable "k8s_token" {
  type        = string
  default     = ""
  description = "Token to auth with the k8s host."
  sensitive   = true
}

variable "k8s_cluster_ca_cert" {
  type        = string
  default     = ""
  description = "CA cert of the k8s host."
  sensitive   = true
}
