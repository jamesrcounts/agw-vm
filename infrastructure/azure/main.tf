locals {
  project = "agw-correlation"

  tags = {
    Environment = "Test"
  }
}

resource "random_pet" "fido" {}