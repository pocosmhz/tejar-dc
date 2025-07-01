data "terraform_remote_state" "tejar_dc" {
  backend = "remote"
  config = {
    organization = "pocosmhz"
    hostname     = "app.terraform.io" # Optional; defaults to app.terraform.io
    workspaces = {
      name = "tejar-dc"
    }
  }
}
