# --- networking/variables.tf ---

variable "vpc_cidr" {
  type = string
  default = "10.0.0.0/16"
}

variable "public_cidrs" {
  type = list(any)
  default = ["10.0.1.0/24", "10.0.2.0/24"]
}
