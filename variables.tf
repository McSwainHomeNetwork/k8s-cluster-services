variable "k8s_host" {
  type        = string
  description = "Address of the k8s host."
  sensitive   = true
}

variable "k8s_client_key" {
  type        = string
  default     = ""
  description = "Private key by which to auth with the k8s host."
  sensitive   = true
}

variable "k8s_cluster_ca_cert" {
  type        = string
  default     = ""
  description = "CA cert of the k8s host."
  sensitive   = true
}

variable "k8s_client_certificate" {
  type        = string
  default     = ""
  description = "CA cert of the k8s host."
  sensitive   = true
}

variable "acme_email_address" {
  type        = string
  sensitive   = true
  description = "Email for ACME"
}

variable "cloudflare_email_address" {
  type        = string
  sensitive   = true
  description = "Email for CloudFlare"
}

variable "cloudflare_api_key" {
  type        = string
  sensitive   = true
  description = "API Key for CloudFlare DNS solver"
}
