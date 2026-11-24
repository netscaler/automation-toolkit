# Content switching and rewrite are disabled by default. Policies still bind
# while a feature is off, but they are never evaluated.
resource "citrixadc_nsfeature" "cs_features" {
    lb      = true
    cs      = true
    rewrite = true
}

resource "citrixadc_csvserver" "cs_vserver" {
    depends_on  = [citrixadc_nsfeature.cs_features]

    name        = var.csvserver_name
    ipv46       = var.netscaler_private_vip
    port        = "80"
    servicetype = "HTTP"
}

# One action, policy and binding per route, e.g. /dev -> dev lbvserver
resource "citrixadc_csaction" "route" {
    for_each        = var.routes
    name            = "${var.csvserver_name}-${each.key}-act"
    targetlbvserver = each.value.lbvserver_name
}

resource "citrixadc_cspolicy" "route" {
    for_each   = var.routes
    policyname = "${var.csvserver_name}-${each.key}-pol"
    rule       = format("HTTP.REQ.URL.PATH.EQ(\"%s\") || HTTP.REQ.URL.PATH.STARTSWITH(\"%s/\")", each.value.path, each.value.path)
    action     = citrixadc_csaction.route[each.key].name
}

resource "citrixadc_csvserver_cspolicy_binding" "route" {
    for_each   = var.routes
    name       = citrixadc_csvserver.cs_vserver.name
    policyname = citrixadc_cspolicy.route[each.key].policyname
    priority   = each.value.priority
}

# Fallback: requests that match no route (including /) go here
resource "citrixadc_csvserver_lbvserver_binding" "default" {
    count     = var.default_lbvserver_name == null ? 0 : 1
    name      = citrixadc_csvserver.cs_vserver.name
    lbvserver = var.default_lbvserver_name
}

# Strip the route prefix before the request reaches the backend: /dev/x -> /x, /dev -> /
# Content switching is decided before rewrite runs, so routing still sees the original path
resource "citrixadc_rewriteaction" "strip_prefix" {
    for_each          = var.strip_path_prefix ? var.routes : {}
    depends_on        = [citrixadc_nsfeature.cs_features]
    name              = "${var.csvserver_name}-${each.key}-strip-act"
    type              = "replace"
    target            = "HTTP.REQ.URL.PATH"
    stringbuilderexpr = format("\"/\" + HTTP.REQ.URL.PATH.AFTER_STR(\"%s\").STRIP_START_CHARS(\"/\")", each.value.path)
}

resource "citrixadc_rewritepolicy" "strip_prefix" {
    for_each = var.strip_path_prefix ? var.routes : {}
    name     = "${var.csvserver_name}-${each.key}-strip-pol"
    rule     = citrixadc_cspolicy.route[each.key].rule
    action   = citrixadc_rewriteaction.strip_prefix[each.key].name
}

resource "citrixadc_csvserver_rewritepolicy_binding" "strip_prefix" {
    for_each               = var.strip_path_prefix ? var.routes : {}
    name                   = citrixadc_csvserver.cs_vserver.name
    policyname             = citrixadc_rewritepolicy.strip_prefix[each.key].name
    priority               = each.value.priority
    bindpoint              = "REQUEST"
    gotopriorityexpression = "END"
}
