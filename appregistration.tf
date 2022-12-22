resource "random_uuid" "uuid" {
    count = 4
}

resource "time_rotating" "rotation" {
  rotation_years = 1
}

data "azuread_client_config" "current" {}

resource "azuread_application" "backoffice" {
  display_name     = "app-mm-back-office-${var.env_name}"
  identifier_uris  = ["api://app-mm-back-office-${var.env_name}"]
  owners           = [data.azuread_client_config.current.object_id]
  sign_in_audience = "AzureADMyOrg"

   app_role {
    allowed_member_types = ["User"]
    description          = "Researcher of back-office"
    display_name         = "BackOffice.Researcher"
    enabled              = true
    id                   = random_uuid.uuid[1].result
    value                = "BackOffice.Researcher"
  }

  app_role {
    allowed_member_types = ["User"]
    description          = "Consultant of back-office"
    display_name         = "BackOffice.Consultant"
    enabled              = true
    id                   = random_uuid.uuid[2].result
    value                = "BackOffice.Consultant"
  }

  app_role {
    allowed_member_types = ["User"]
    description          = "Admin of back-office"
    display_name         = "BackOffice.Admin"
    enabled              = true
    id                   = random_uuid.uuid[3].result
    value                = "BackOffice.Admin"
  }

  api {
    oauth2_permission_scope {
      admin_consent_description  = "Allow the Web API to identify what kind of user made a request."
      admin_consent_display_name = "BackOffice.User"
      enabled                    = true
      id                         = random_uuid.uuid[0].result
      type                       = "Admin"
      value                      = "BackOffice.User"
    }
  }

  required_resource_access {
    resource_app_id = "00000003-0000-0000-c000-000000000000" # Microsoft Graph

    resource_access {
      id   = "df021288-bdef-4463-88db-98f22de89214" # User.Read.All Application
      type = "Role"
    }

    resource_access {
      id   = "98830695-27a2-44f7-8c18-0c3ebc9698f6" # GroupMember.Read.All Application
      type = "Role"
    }

    resource_access {
      id   = "e1fe6dd8-ba31-4d61-89e7-88639da4683d" # User.Read Delegated
      type = "Scope"
    }
  }

  single_page_application {

    redirect_uris = ( var.env_name == "prod" ? [
        "https://${azurerm_static_site.web.default_host_name}/",
        "https://${azurerm_static_site.selfservice.default_host_name}/back-office",
        "https://backoffice.${var.custom_domain}/",
        "https://portal.${var.custom_domain}/back-office"
        ] : [
        "https://app-mm-back-office-${var.env_name}.azurewebsites.net/swagger/oauth2-redirect.html",
        "https://app-mm-tagsystem-${var.env_name}.azurewebsites.net/swagger/oauth2-redirect.html",
        "https://app-mm-company-${var.env_name}.azurewebsites.net/swagger/oauth2-redirect.html",
        "https://app-mm-candidate-${var.env_name}.azurewebsites.net/swagger/oauth2-redirect.html",
        "https://app-mm-job-${var.env_name}.azurewebsites.net/swagger/oauth2-redirect.html",
        "https://${azurerm_static_site.web.default_host_name}/",
        "https://${azurerm_static_site.selfservice.default_host_name}/back-office",
        "https://backoffice.${var.custom_domain}/",
        "https://portal.${var.custom_domain}/back-office",
        "https://bo-api.${var.custom_domain}/swagger/oauth2-redirect.html",
        "http://localhost:3000/",
        "http://localhost:3000/back-office",
        "http://localhost:3001/",
        "http://localhost:3001/back-office",
        "http://localhost:5101/swagger/oauth2-redirect.html",
        "http://localhost:5011/swagger/oauth2-redirect.html",
        "http://localhost:5012/swagger/oauth2-redirect.html",
        "http://localhost:5013/swagger/oauth2-redirect.html",
        "http://localhost:5014/swagger/oauth2-redirect.html"
        ]
    )
  }

  web {
    redirect_uris = null

    implicit_grant {
        access_token_issuance_enabled = ( var.env_name == "prod" ? false : true )
        id_token_issuance_enabled     = ( var.env_name == "prod" ? false : true )
      }
  }

  lifecycle {
    ignore_changes = [
      required_resource_access
    ]
  }
}

resource "azuread_application_password" "pwd" {
  display_name          = "InitSecret"
  application_object_id = azuread_application.backoffice.object_id
  rotate_when_changed   = {
    rotation = time_rotating.rotation.id
  }

  depends_on = [
    azuread_application.backoffice
  ]
}

resource "azuread_service_principal" "backoffice" {
  application_id               = azuread_application.backoffice.application_id
  app_role_assignment_required = false
  owners                       = [data.azuread_client_config.current.object_id]

  feature_tags {
    hide = true
  }

  depends_on = [
    azuread_application.backoffice
  ]
}

