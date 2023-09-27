module "a" {
  source  = ".//a_aaaa"
  records = var.a
  zone    = var.zone
  type    = "A"
}

module "aaaa" {
  source  = ".//a_aaaa"
  records = var.aaaa
  zone    = var.zone
  type    = "AAAA"
}

module "caa" {
  source  = ".//caa"
  records = var.caa
  zone    = var.zone
}

module "cname" {
  source  = ".//generic"
  records = var.cname
  zone    = var.zone
  type    = "CNAME"
}

module "txt" {
  source  = ".//generic"
  records = var.txt
  zone    = var.zone
  type    = "TXT"
}

module "ns" {
  source  = ".//generic"
  records = var.ns
  zone    = var.zone
  type    = "NS"
}

module "mx" {
  source  = ".//mx"
  records = var.mx
  zone    = var.zone
}

module "soa" {
  source  = ".//generic"
  records = var.soa
  zone    = var.zone
  type    = "SOA"
}
