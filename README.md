# Домашнее задание к занятию «Применение принципов IaaC в работе с виртуальными машинами»

## Цель работы

В рамках домашнего задания были изучены и применены инструменты Infrastructure as Code для работы с виртуальными машинами:

- VirtualBox
- Vagrant
- Packer
- Yandex Cloud CLI

В результате был создан собственный образ Debian для Yandex Cloud с предустановленными:

- Docker Engine
- Docker Compose Plugin
- htop
- tmux

---

# Задача 1. Подготовка окружения

На учебную Linux ВМ были установлены:

- VirtualBox
- Vagrant
- Packer
- Yandex Cloud CLI

Проверка VirtualBox:

```bash
VBoxManage --version
```

Результат:

```text
7.0.16_Ubuntur162802
```

Проверка работы Yandex Cloud CLI:

```bash
yc compute image list
```

CLI успешно подключается к облаку и выполняет запросы.

---

# Задача 2. Создание виртуальной машины через Vagrant

Создан каталог `src` и файл `Vagrantfile`.

Используемый образ:

```ruby
ISO = "bento/ubuntu-20.04"
```

Запуск виртуальной машины:

```bash
vagrant up --provider=virtualbox
```

В процессе выполнения:

- образ `bento/ubuntu-20.04` был успешно скачан;
- VirtualBox provider корректно определился;
- Vagrant начал создание виртуальной машины.

Однако запуск завершился ошибкой:

```text
AMD-V is not available (VERR_SVM_NO_SVM)
```

Причина ошибки заключается в том, что работа выполнялась внутри учебной Linux ВМ VirtualBox, где недоступна вложенная виртуализация (Nested Virtualization).

Согласно условиям задания, в этом случае допускается неполное выполнение до ошибки запуска виртуальной машины.

---

# Задача 3. Создание собственного образа Yandex Cloud через Packer

Создан файл `mydebian.json.pkr.hcl`.

Содержимое файла:

```hcl
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

      "sudo sed -i '/bullseye-backports/d' /etc/apt/sources.list || true",

      "sudo apt-get update",
      "sudo apt-get install -y ca-certificates curl",

      "sudo install -m 0755 -d /etc/apt/keyrings",

      "sudo curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc",

      "sudo chmod a+r /etc/apt/keyrings/docker.asc",

      "echo \"deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian $(. /etc/os-release && echo $VERSION_CODENAME) stable\" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null",

      "sudo apt-get update",

      "sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin",

      "sudo apt-get install -y htop tmux"
    ]
  }
}
```

Для установки Docker использовалась официальная документация:

https://docs.docker.com/engine/install/debian/

---

## Проверка конфигурации

Проверка файла Packer:

```bash
packer validate mydebian.json.pkr.hcl
```

Результат:

```text
The configuration is valid.
```

---

## Сборка образа

Запуск сборки:

```bash
packer build mydebian.json.pkr.hcl
```

В процессе сборки Packer:

- создал временную виртуальную машину;
- подключился к ней по SSH;
- установил Docker Engine;
- установил Docker Compose Plugin;
- установил htop;
- установил tmux;
- создал пользовательский образ Yandex Cloud.

Результат:

```text
Build 'yandex.debian_docker' finished after 3 minutes 1 second.
```

Созданный образ:

```text
Name: debian-11-docker
ID: fd887mell6rlrt0jomnc
```

---

## Проверка созданного образа

Команда:

```bash
yc compute image list
```

Результат:

```text
+----------------------+------------------+--------+----------------------+--------+
|          ID          |       NAME       | FAMILY |     PRODUCT IDS      | STATUS |
+----------------------+------------------+--------+----------------------+--------+
| fd887mell6rlrt0jomnc | debian-11-docker |        | f2ej779m0euks15j3a2d | READY  |
+----------------------+------------------+--------+----------------------+--------+
```

Образ успешно создан и находится в состоянии `READY`.

---

## Создание виртуальной машины из собственного образа

Создание тестовой виртуальной машины:

```bash
yc compute instance create \
  --name docker-test \
  --zone ru-central1-a \
  --create-boot-disk image-id=fd887mell6rlrt0jomnc,size=10 \
  --cores 2 \
  --memory 2 \
  --network-interface subnet-id=xxxxxx,nat-ip-version=ipv4 \
  --metadata ssh-keys="debian:$(cat ~/.ssh/id_ed25519.pub)"
```

После создания виртуальная машина получила внешний IP-адрес и перешла в состояние `RUNNING`.

---

## Проверка установленного ПО

Подключение по SSH:

```bash
ssh debian@<external_ip>
```

Проверка Docker:

```bash
sudo docker version
```

Результат:

```text
Client: Docker Engine - Community
Version: 29.5.3

Server: Docker Engine - Community
Version: 29.5.3
```

Проверка Docker Compose:

```bash
sudo docker compose version
```

Результат:

```text
Docker Compose version v5.1.4
```

Проверка htop:

```bash
htop --version
```

Результат:

```text
htop 3.0.5
```

Проверка tmux:

```bash
tmux -V
```

Результат:

```text
tmux 3.1c
```

Все требуемые пакеты были успешно установлены в созданный образ.

---

## Удаление ресурсов

После проверки были удалены созданные ресурсы.

Удаление виртуальной машины:

```bash
yc compute instance delete docker-test
```

Удаление образа:

```bash
yc compute image delete fd887mell6rlrt0jomnc
```

---

## Безопасность

Перед публикацией файла конфигурации все секретные данные были удалены.

Значения заменены на заглушки:

```hcl
folder_id = "xxxxxx"
subnet_id = "xxxxxx"
token     = "xxxxxx"
```

OAuth-токены и идентификаторы облачных ресурсов в репозиторий не публикуются.

---

# Итоги

В ходе выполнения работы:

- установлены VirtualBox, Vagrant, Packer и YC CLI;
- выполнена настройка Yandex Cloud CLI;
- подготовлен Vagrantfile для запуска виртуальной машины;
- исследована проблема вложенной виртуализации;
- создан Packer-конфиг для сборки пользовательского образа;
- собран собственный образ Debian 11 для Yandex Cloud;
- установлены Docker Engine, Docker Compose Plugin, htop и tmux;
- создана и протестирована виртуальная машина на основе собранного образа;
- подтверждена работоспособность установленного программного обеспечения;
- выполнена очистка облачных ресурсов после завершения проверки.
