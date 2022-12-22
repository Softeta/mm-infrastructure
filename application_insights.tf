resource "azurerm_application_insights" "apinsights" {
  name                 = "appi-${var.project_name}-platform-${var.env_name}"
  resource_group_name  = azurerm_resource_group.rg["platform"].name
  location             = azurerm_resource_group.rg["platform"].location
  workspace_id         = azurerm_log_analytics_workspace.alaworkspace.id
  application_type     = "web"

  tags = {
    Environment = var.env_name,
  }
}

resource "azurerm_application_insights_web_test" "availability_backend" {
  for_each                = azurerm_linux_web_app.backend 
  name                    = "${each.value.name}-health"
  location                = azurerm_application_insights.apinsights.location
  resource_group_name     = azurerm_application_insights.apinsights.resource_group_name
  application_insights_id = azurerm_application_insights.apinsights.id
  kind                    = "ping"
  frequency               = 300
  timeout                 = 30
  enabled                 = true
  retry_enabled           = false
  geo_locations           = ["emea-fr-pra-edge", "emea-gb-db3-azr", "emea-se-sto-edge", "emea-nl-ams-azr", "emea-ru-msa-edge" ]

  configuration = <<XML
<WebTest
 Name="${each.value.name}-health"
 Id="ABD48585-0831-40CB-9069-682EA6BB3583"
 Enabled="True"
 CssProjectStructure=""
 CssIteration=""
 Timeout="30"
 WorkItemIds=""
 xmlns="http://microsoft.com/schemas/VisualStudio/TeamTest/2010"
 Description=""
 CredentialUserName=""
 CredentialPassword=""
 PreAuthenticate="True"
 Proxy="default"
 StopOnError="False"
 RecordedResultFile=""
 ResultsLocale=""
 >
  <Items>
    <Request
    Method="GET"
    Guid="a5f10126-e4cd-570d-961c-cea43999a200"
    Version="1.1"
    Url="https://${each.value.default_hostname}/api/health"
    ThinkTime="0"
    Timeout="30"
    ParseDependentRequests="True"
    FollowRedirects="True"
    RecordResult="True"
    Cache="False"
    ResponseTimeGoal="0"
    Encoding="utf-8"
    ExpectedHttpStatusCode="200"
    ExpectedResponseUrl=""
    ReportingName=""
    IgnoreHttpStatusCode="False"
    />
  </Items>
</WebTest>
XML
}

resource "azurerm_application_insights_web_test" "availability_apigateway" {
  for_each                = azurerm_linux_web_app.apigateway
  name                    = "${each.value.name}-health"
  location                = azurerm_application_insights.apinsights.location
  resource_group_name     = azurerm_application_insights.apinsights.resource_group_name
  application_insights_id = azurerm_application_insights.apinsights.id
  kind                    = "ping"
  frequency               = 300
  timeout                 = 30
  enabled                 = true
  retry_enabled           = false
  geo_locations           = ["emea-nl-ams-azr", "emea-ru-msa-edge", "emea-se-sto-edge", "emea-gb-db3-azr", "emea-fr-pra-edge"]

  configuration = <<XML
<WebTest
 Name="${each.value.name}-health"
 Id="ABD48585-0831-40CB-9069-682EA6BB3583"
 Enabled="True"
 CssProjectStructure=""
 CssIteration=""
 Timeout="30"
 WorkItemIds=""
 xmlns="http://microsoft.com/schemas/VisualStudio/TeamTest/2010"
 Description=""
 CredentialUserName=""
 CredentialPassword=""
 PreAuthenticate="True"
 Proxy="default"
 StopOnError="False"
 RecordedResultFile=""
 ResultsLocale=""
 >
  <Items>
    <Request
    Method="GET"
    Guid="a5f10126-e4cd-570d-961c-cea43999a200"
    Version="1.1"
    Url="https://${each.value.default_hostname}/api/health"
    ThinkTime="0"
    Timeout="30"
    ParseDependentRequests="True"
    FollowRedirects="True"
    RecordResult="True"
    Cache="False"
    ResponseTimeGoal="0"
    Encoding="utf-8"
    ExpectedHttpStatusCode="200"
    ExpectedResponseUrl=""
    ReportingName=""
    IgnoreHttpStatusCode="False"
    />
  </Items>
</WebTest>
XML
}