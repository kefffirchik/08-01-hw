# Домашнее задание к занятию "Репликация и масштабирование. Часть 1" Nikiforov Viktor

### Задание 1

## На лекции рассматривались режимы репликации master-slave, master-master, опишите их различия.

	Основное различие между этими режимами заключается в том, что в master-slave запись производится только на одном сервере, а в master-master запись возможна на обоих серверах, при этом данные синхронизируются между ними.

---

### Задание 2

## Выполните конфигурацию master-slave репликации, примером можно пользоваться из лекции.

## Docker Containers
![Containers](img/ReplicaSQL/dockermscont.png)

## Master Status
![Status](img/ReplicaSQL/masstatus.png)

## Replica Status
![Status](img/ReplicaSQL/repstatus.png)

## Replica Check
![Check](img/ReplicaSQL/repdb.png)

---

### Задание 3

## Выполните конфигурацию master-master репликации. Произведите проверку.

## Replica Status 1
![Status](img/ReplicaSQL/replmaster1.png)

## Replica Status 2
![Status](img/ReplicaSQL/replmaster2.png)

## Data Create 1
![Data](img/ReplicaSQL/master1_create.png)

## Data Check 1
![Check](img/ReplicaSQL/master2_check.png)

## Data Create 2
![Data](img/ReplicaSQL/master2_create.png)

## Data Check 2
![Check](img/ReplicaSQL/master1_check.png)

---
