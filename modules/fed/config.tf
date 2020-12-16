resource "kubernetes_config_map" "data" {
  metadata {
    name = "fed-data"
    namespace = var.namespace
  }

  data = {
    "ach.json" = fileexists(var.fedach_data_filepath) ? trimspace(file(var.fedach_data_filepath)) : ""
    "wire.json" = fileexists(var.fedwire_data_filepath) ? trimspace(file(var.fedwire_data_filepath)) : ""
  }
}
