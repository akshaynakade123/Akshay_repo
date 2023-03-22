variable "tag_1" {
  type    = string
  default = "for_study_purpose"

}

variable "subnet_var" {
  type    = list(any)
  default = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24", "10.0.4.0/24"]
}

variable "az_var" {
  type    = list(any)
  default = ["us-east-1b", "us-east-1c", "us-east-1d", "us-east-1e"]

}

variable "rds_instance_identifier" {
  type    = string
  default = "terraform-mysql"
}

variable "frontend" {
  type    = string
  default = "terraform-mysql"
}

variable "database_name" {
  type    = string
  default = "terraform_test_db"
}

variable "database_user" {
  type    = string
  default = "terraform"
}

variable "database_password" {
  type    = string
  default = "terraform1234"
}











