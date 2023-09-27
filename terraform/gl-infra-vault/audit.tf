resource "vault_audit" "file" {
  path = "file"
  type = "file"

  options = {
    file_path = "stdout"
  }
}
