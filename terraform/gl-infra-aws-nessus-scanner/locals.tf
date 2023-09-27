## Process some inputs into a map of tags, then use those instead

locals {
  instance_name = coalesce(
    var.instance_name,                       # Prefer explicit name input
    lookup(var.instance_tags, "Name", null), # Allow naming with tags
    "nessus-scanner"                         # Default instance name
  )
  instance_tags = merge(var.instance_tags, { "Name" = local.instance_name }) # The right-most map's value always wins
}
