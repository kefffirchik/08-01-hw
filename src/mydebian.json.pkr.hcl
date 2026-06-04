source "yandex" "debian_docker" {
  disk_type           = "network-hdd"
  folder_id           = "xxxxxx"
  image_description   = "my custom debian with docker"
  image_name          = "debian-11-docker"
  source_image_family = "debian-11"
  ssh_username        = "debian"
  subnet_id           = "xxxxxx"
  token               = "xxxxxx"
  use_ipv4_nat        = true
  zone                = "ru-central1-a"
}

build {
  sources = ["source.yandex.debian_docker"]

provisioner "shell" {
  inline = [
    "export DEBIAN_FRONTEND=noninteractive",

    # Исправление образа Debian от YC
    "sudo sed -i '/bullseye-backports/d' /etc/apt/sources.list || true",

    # Документация Docker
    "sudo apt-get update",
    "sudo apt-get install -y ca-certificates curl",

    "sudo install -m 0755 -d /etc/apt/keyrings",

    "sudo curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc",

    "sudo chmod a+r /etc/apt/keyrings/docker.asc",

    "echo \"deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian $(. /etc/os-release && echo $VERSION_CODENAME) stable\" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null",

    "sudo apt-get update",

    "sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin",

    # Требование задания
    "sudo apt-get install -y htop tmux"
  ]
}
}
