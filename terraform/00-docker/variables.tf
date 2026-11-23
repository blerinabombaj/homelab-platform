# variables.tf: the INPUTS of this module. Values come from (highest priority first):
#   -var on the CLI > *.auto.tfvars / terraform.tfvars > TF_VAR_<name> env vars > default below

variable "postgres_user" {
  description = "Postgres superuser name"
  type        = string
  default     = "postgres"
}

variable "postgres_password" {
  description = "Postgres password. No default on purpose: you must provide it."
  type        = string
  # sensitive = Terraform hides it in plan/apply output.
  # It is STILL stored in plain text in terraform.tfstate, which is why *.tfstate is gitignored.
  sensitive = true
}

variable "postgres_db" {
  description = "Database name"
  type        = string
  default     = "postgres"
}

variable "vote_port" {
  description = "Host port for the vote UI (different from compose's 8080, so both can coexist)"
  type        = number
  default     = 9080
}

variable "result_port" {
  description = "Host port for the result UI"
  type        = number
  default     = 9081
}

variable "options" {
  description = "The two choices shown on the vote page"
  type = object({
    a = string
    b = string
  })
  default = {
    a = "Cats"
    b = "Dogs"
  }
}
