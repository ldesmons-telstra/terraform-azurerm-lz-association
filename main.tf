/* -----------------------
   TF main config.
   -----------------------
*/

terraform {
  required_version = ">= 0.12.24"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.0.0"
    }
  }
}