# main.tf: the same stack as compose.yaml, written as Terraform resources.
#   cd terraform/00-docker
#   cp example.tfvars terraform.tfvars   # set the password (terraform.tfvars is gitignored)
#   terraform init      # download the provider
#   terraform plan      # show what WOULD change (read it every time!)
#   terraform apply     # do it
#   -> vote http://<pc>:9080   result http://<pc>:9081
#
# Compose vs Terraform: compose is a dev tool for containers. Terraform manages ANY
# infrastructure (Docker, Kubernetes, AWS...) and keeps a STATE file of what it created,
# so it can compute diffs and destroy exactly what it made. Same concepts, different scope.

# "locals" = named values computed inside the module (like local variables).
locals {
  prefix   = "tf"                         # container name prefix, avoids clashing with compose
  app_dir  = "${path.module}/../../app"   # path.module = the folder of this .tf file
  services = ["vote", "result", "worker"] # services we build ourselves

  # Postgres connection settings, shared by worker and db.
  pg_env = [
    "POSTGRES_USER=${var.postgres_user}",
    "POSTGRES_PASSWORD=${var.postgres_password}",
    "POSTGRES_DB=${var.postgres_db}",
  ]
}

# ---------------- Networks (= compose "networks:") ----------------
resource "docker_network" "front" {
  name = "${local.prefix}-front"
}

resource "docker_network" "back" {
  name = "${local.prefix}-back"
}

# ---------------- Volume (= compose "volumes:") ----------------
resource "docker_volume" "db_data" {
  name = "${local.prefix}-db-data"
  # Safety net: `terraform destroy` refuses to delete the volume holding the data.
  # Remove this line on purpose if you really want to wipe it.
  lifecycle {
    prevent_destroy = true
  }
}

# ---------------- Images we build ----------------
# for_each = create one resource per item. Gives docker_image.app["vote"], ["result"], ["worker"].
resource "docker_image" "app" {
  for_each = toset(local.services)

  name = "homelab/${each.key}:tf"
  build {
    context = "${local.app_dir}/${each.key}"
  }

  # Terraform only rebuilds when an argument changes. This hash of every file in the
  # service folder changes whenever you edit the code -> triggers a rebuild.
  triggers = {
    src_hash = sha1(join("", [
      for f in fileset("${local.app_dir}/${each.key}", "**") :
      filesha1("${local.app_dir}/${each.key}/${f}")
    ]))
  }

  keep_locally = true # on destroy, keep the image in Docker (faster next time)
}

# Images we pull from Docker Hub instead of building.
resource "docker_image" "redis" {
  name         = "redis:8-alpine"
  keep_locally = true
}

resource "docker_image" "postgres" {
  name         = "postgres:18-alpine"
  keep_locally = true
}

# ---------------- Containers ----------------
resource "docker_container" "redis" {
  name    = "${local.prefix}-redis"
  image   = docker_image.redis.image_id # a reference = implicit dependency: image is created first
  restart = "unless-stopped"

  networks_advanced {
    name = docker_network.back.name
    # aliases = extra DNS names on this network. The apps look for "redis" and "db",
    # so the containers answer to those names even though they're called tf-redis / tf-db.
    aliases = ["redis"]
  }

  healthcheck {
    test     = ["CMD", "redis-cli", "ping"]
    interval = "5s"
    timeout  = "3s"
    retries  = 5
  }
}

resource "docker_container" "db" {
  name    = "${local.prefix}-db"
  image   = docker_image.postgres.image_id
  restart = "unless-stopped"
  env     = local.pg_env

  networks_advanced {
    name    = docker_network.back.name
    aliases = ["db"]
  }

  volumes {
    volume_name    = docker_volume.db_data.name
    container_path = "/var/lib/postgresql" # Postgres 18+ path (see compose.yaml)
  }

  healthcheck {
    test     = ["CMD-SHELL", "pg_isready -U $${POSTGRES_USER}"] # $$ = literal $ (same as compose)
    interval = "5s"
    timeout  = "3s"
    retries  = 5
  }

  # wait = Terraform waits until the container is HEALTHY before marking it created.
  # That's how we get compose's "condition: service_healthy" behaviour.
  wait         = true
  wait_timeout = 60
}

resource "docker_container" "vote" {
  name    = "${local.prefix}-vote"
  image   = docker_image.app["vote"].image_id
  restart = "unless-stopped"
  env = [
    "REDIS_HOST=redis",
    "OPTION_A=${var.options.a}",
    "OPTION_B=${var.options.b}",
  ]

  ports {
    internal = 8080
    external = var.vote_port
  }

  # A container can join several networks: one block per network.
  networks_advanced {
    name = docker_network.front.name
  }
  networks_advanced {
    name = docker_network.back.name
  }

  # Explicit dependency: there's no reference to redis in the arguments, so tell Terraform.
  depends_on = [docker_container.redis]
}

resource "docker_container" "result" {
  name    = "${local.prefix}-result"
  image   = docker_image.app["result"].image_id
  restart = "unless-stopped"
  init    = true
  env = [
    "DATABASE_URL=postgres://${var.postgres_user}:${var.postgres_password}@db/${var.postgres_db}",
  ]

  ports {
    internal = 4000
    external = var.result_port
  }

  networks_advanced {
    name = docker_network.front.name
  }
  networks_advanced {
    name = docker_network.back.name
  }

  depends_on = [docker_container.db]
}

resource "docker_container" "worker" {
  name    = "${local.prefix}-worker"
  image   = docker_image.app["worker"].image_id
  restart = "unless-stopped"
  # concat = join lists: the worker needs the Postgres vars plus its hostnames.
  env = concat(local.pg_env, ["REDIS_HOST=redis", "DB_HOST=db"])

  networks_advanced {
    name = docker_network.back.name
  }

  depends_on = [docker_container.redis, docker_container.db]
}
