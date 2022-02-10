variable "plex_ip" {
    type = string
    sensitive = true
}

variable "home_assistant_ip" {
    type = string
    sensitive = true
}

variable "domain_name" {
    type = string
    default = "mcswain.dev"
}