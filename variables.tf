variable "subnet_names" {
  default = ["frontend", "backend"]
  type    = list(string)
}

variable "subnet" {
  default = {
    "prod" = 0
    "test" = 1
    "dev"  = 2
    "sand" = 3
  }
}

variable "sqs_data" {
  description   = "Application object map"
  default = {
    platform = {
        rg_name      = "platform"
        sb_topic_sub = {
          "candidate_changed"        = ["EmailService", "JobService", "ElasticSearch", "CandidateService", "EmailServiceSync"]
          "company_changed"          = ["EmailService", "JobService", "CompanyService"]
          "backofficeuser_changed"   = ["JobService"]
          "candidatejobs_changed"    = ["ElasticSearch", "JobService", "EmailService"]
          "job_changed"              = ["TagsSystem", "CompanyService", "EmailService", "ElasticSearch"]
          "jobcandidates_changed"    = ["CandidateService", "EmailService", "ElasticSearch"]
          "job_share_changed"        = ["EmailService"]
          "email_service_web_hooked" = ["JobService", "CandidateService"]
          "schedulerjob_scheduled"   = ["CandidateService", "CompanyService"],
          "contactperson_changed"    = ["EmailService", "JobService", "CompanyService", "EmailServiceSync"],
          "jobposition_changed"      = ["CandidateService", "JobService", "CompanyService"],
          "skill_changed"            = ["CandidateService", "JobService"]
          }
        storage      = {
          "candidate-certificates"     = "private",
          "candidate-videos"           = "private",
          "candidate-curriculumvitaes" = "private",
          "candidate-motivationvideos" = "private",
          "candidate-test-raports"     = "private"
        }
        own_app_plan  = "time-triggers"
        time_trigger  = { 
          plan_name = "time-triggers"
        }
        fun_app_name  = ["scheduler-job"]
        app_plan      = "platform"
        sku_plan      = {
          sand    = "B1"
          dev     = "B3"
          test    = "P2v2"
          prod    = "P2v2"
        }
        cr_name       = "platform"
        sb_sas        = "scheduler-job-service"
        subnet        = "backend"
    },
    web = {
        rg_name       = "web"
        app_name      = ["back-office", "front-office"]
        app_plan      = "web"
        sku_plan      = {
          sand    = "B1"
          dev     = "B2"
          test    = "P1v2"
          prod    = "P2v2"
        }
        time_trigger  = { 
          plan_name = "time-triggers"
        }
        fun_app_name  = ["back-office-users-cache-refresher"]
        storage       = {
          "backofficeusers"  = "private"
        }
        kv_st_name    = "web"
        sb_sas        = "web-jobs"
        subnet        = "apigateway"
    },
    job = {
        rg_name       = "job"
        app_name      = ["job"]
        app_plan      = "platform"
        sql_name      = "job"
        sql_sku       = {
          sand    = "Basic"
          dev     = "Basic"
          test    = "S1"
          prod    = "S4"
        }
        sb_sas        = "job-service"
        subnet        = "backend"
    },
    company = {
        rg_name       = "company"
        app_name      = ["company"]
        app_plan      = "platform"
        sql_name      = "company"
        sql_sku       = {
          sand    = "Basic"
          dev     = "Basic"
          test    = "S0"
          prod    = "S2"
        }
        sb_sas        = "company-service"
        subnet        = "backend"
    }
    candidate = {
        rg_name       = "candidate"
        app_name      = ["candidate"]
        app_plan      = "platform"
        sql_name      = "candidate"
        sql_sku       = {
          sand    = "Basic"
          dev     = "Basic"
          test    = "S1"
          prod    = "S4"
        }
        sb_sas        = "candidate-service"
        subnet        = "backend"
    }
    elastic-search = {
        rg_name       = "elastic-search"
        func_app_plan = "platform"
        fun_app_name  = ["elastic-search-sync", "elastic-search-search"]
        srch_name     = "elastic-search"
        sb_sas        = "elastic-search-service"
    }
    administration-settings = {
        rg_name       = "administration-settings"
        app_name      = ["administration-settings"]
        app_plan      = "platform"
    }
    email-service = {
        rg_name       = "email-service"
        func_app_plan = "platform"
        fun_app_name  = ["email-service-send", "email-service-webhook", "email-service-sync"]
        sb_sas        = "email-service"
    }
    tags = {
        rg_name            = "tags"
        app_container_name = ["tags"]
        app_plan           = "web"
        psql_name          = "tags"
        container_image    = "tags"
        subnet             = "apigateway"
    }
    tags-jobs-created = {
        rg_name       = "tags-jobs-created"
        own_app_plan  = "tags-jobs-created"
        fun_app_name  = ["tags-jobs-created"]
        sb_sas        = "tags-service"
    }
  }
}

variable "public_storage_account" {
  default = {
      "candidate-profilepictures" = "blob",
      "company-contactpictures"   = "blob",
      "company-logos"             = "blob",
      "backoffice-userpictures"   = "blob",
      "b2c-company-templates"     = "blob",
      "b2c-candidate-templates"   = "blob",
      "media"                     = "blob"
  }
}

variable "resource_group_location" {
  default = "westeurope"
  description   = "Location of the resource group."
}

variable "project_name" {
  default = "mm"
  description = "Project short name"
}

variable "env_name" {
  default = "dev"
  description = "Application environment"
  validation {
    condition = contains (["sand", "dev", "test", "prod"], var.env_name)
    error_message = "Valid value is one of the following: sand, dev, test, prod."
  }
}

variable "b2c_candidates_domain" {
  default = "marchermarholtcandidates"
  description   = "Azure AD B2C Candidates tenant domain"
}

variable "b2c_companies_domain" {
  default = "marchermarholtcompanies"
  description   = "Azure AD B2C Companies tenant domain"
}

variable "custom_domain" {
  default = "mmtest1.com"
  description   = "Custom domain"
}

// Secrets
variable "secret_sendinblue" {
  description = "Email service send in blue key"
  type        = string
  sensitive   = true
}

variable "secret_heresearch" {
  description = "Here search API key"
  type        = string
  sensitive   = true
}

variable "secret_talogy" {
  description = "Talogy API client secret"
  type        = string
  sensitive   = true
}

variable "secret_candidate" {
  description = "Candidate service client app registration secret"
  type        = string
  sensitive   = true
}

variable "secret_company" {
  description = "Company service client app registration secret"
  type        = string
  sensitive   = true
}

variable "secret_danishcrv" {
  description = "Danish CRV Api user password"
  type        = string
  sensitive   = true
}

variable "secret_weawy" {
  description = "Weawy API secret"
  type        = string
  sensitive   = true
}

variable "secret_formrecognizerkey" {
  description = "Form recognizer key"
  type        = string
  sensitive   = true
}

// Variables used for statemain.tf

variable "env_state" {
  default = "nonprod"
  description = "Application environment"
  validation {
    condition = contains (["nonprod", "prod"], var.env_state)
    error_message = "Valid value is one of the following: nonprod, prod."
  }
}
