variable "acme_email_address" {
    type = string
    sensitive = true
    description = "Email for ACME"
}

variable "cloudflare_email_address" {
    type = string
    sensitive = true
    description = "Email for CloudFlare"
}

variable "cloudflare_api_key" {
    type = string
    sensitive = true
    description = "API Key for CloudFlare DNS solver"
}
