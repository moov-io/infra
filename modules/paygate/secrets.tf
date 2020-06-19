resource "kubernetes_secret" "paygate-config" {
  metadata {
    name = "paygate-config"
    namespace = var.namespace
  }

  data = {
    "config.yaml" = "${file(var.config_filepath)}"
  }
}

resource "kubernetes_secret" "paygate-preupload-gpg-key-file" {
  metadata {
    name = "paygate-preupload-gpg-key"
    namespace = var.namespace
  }

  data = {
    "pre-upload.pub" = "${file(var.pre_upload_gpg_public_key_file)}"
    "pre-upload.key" = "${file(var.pre_upload_gpg_public_signing_key_file)}"
  }
}

resource "kubernetes_secret" "paygate-google-application-credentials" {
  metadata {
    name = "paygate-google-application-credentials"
    namespace = var.namespace
  }

  data = {
    "credentials.json" = "${file(var.google_application_credentials_filepath)}"
  }
}

resource "kubernetes_secret" "paygate-audit-trail-gpg-key" {
  metadata {
    name = "paygate-audit-trail-gpg-key"
    namespace = var.namespace
  }

  data = {
    "audit.pub" = "${file(var.audit_trail_gpg_key_file)}"
  }
}
