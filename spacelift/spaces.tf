resource "spacelift_space" "infrastructure" {
  name             = "infrastructure"
  description      = "This a child of the root space. It contains all the resources common to the infrastructure."
  parent_space_id  = "root"
  inherit_entities = true
}

resource "spacelift_space" "networking" {
  name             = "networking"
  description      = "This space contains all networking related resources."
  parent_space_id  = spacelift_space.infrastructure.id
  inherit_entities = true
}

resource "spacelift_space" "compute" {
  name             = "compute"
  description      = "This space contains all compute related resources."
  parent_space_id  = spacelift_space.infrastructure.id
  inherit_entities = true
}

resource "spacelift_space" "storage" {
  name             = "storage"
  description      = "This space contains all storage related resources."
  parent_space_id  = spacelift_space.infrastructure.id
  inherit_entities = true
}

resource "spacelift_space" "storage-prod" {
  name             = "storage-prod"
  description      = "This space contains all production storage related resources."
  parent_space_id  = spacelift_space.storage.id
  inherit_entities = true
}

resource "spacelift_space" "storage-nonprod" {
  name             = "storage-nonprod"
  description      = "This space contains all non-production storage related resources."
  parent_space_id  = spacelift_space.storage.id
  inherit_entities = true
}
