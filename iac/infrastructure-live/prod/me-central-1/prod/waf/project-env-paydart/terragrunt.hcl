include "root" {
  path           = find_in_parent_folders()
  expose         = true
  merge_strategy = "deep"
}

terraform {
  source = "../../../../../../terraform/modules//waf"
  extra_arguments "init_args" {
    commands = [
      "init"
    ]
  }
}




inputs = {
  name_prefix            = include.root.locals.resource_name
  description            = format("%s-DevOps", include.root.locals.resource_name)
  alb_arn                = "arn:aws:elasticloadbalancing:af-south-1:replace-me"
  scope                  = "REGIONAL"
  create_alb_association = true
  allow_default_action   = true

  visibility_config = {
    metric_name = format("%s-metrics", include.root.locals.resource_name)
  }

  rules = [
    {
      name     = "AWSManagedRulesCommonRuleSet-rule-30"
      priority = "1"

      override_action = "none"
      visibility_config = {
        metric_name = "AWSManagedRulesCommonRuleSet-metric"
      }

      managed_rule_group_statement = {
        name        = "AWSManagedRulesCommonRuleSet"
        vendor_name = "AWS"
        excluded_rule = [
          "SizeRestrictions_BODY",
          "CrossSiteScripting_BODY"
        ]
      }
    },
    {
      name     = "AWSManagedRulesPHPRuleSet-rule-31"
      priority = "2"

      override_action = "none"

      visibility_config = {
        cloudwatch_metrics_enabled = false
        metric_name                = "AWSManagedRulesPHPRuleSet-metric"
        sampled_requests_enabled   = false
      }

      managed_rule_group_statement = {
        name        = "AWSManagedRulesPHPRuleSet"
        vendor_name = "AWS"
      }
    },
    {
      name     = "AWSManagedRulesSQLiRuleSet-rule-32"
      priority = "3"

      override_action = "none"

      visibility_config = {
        cloudwatch_metrics_enabled = false
        metric_name                = "AWSManagedRulesSQLiRuleSet-metric"
        sampled_requests_enabled   = false
      }

      managed_rule_group_statement = {
        name        = "AWSManagedRulesSQLiRuleSet"
        vendor_name = "AWS"
        excluded_rule = [
          "SQLi_BODY"
        ]
      }
    },
    {
      name     = "AllowURLS"
      priority = "4"

      action = "allow"

      visibility_config = {
        cloudwatch_metrics_enabled = true
        metric_name                = "AllowURLS-metric"
        sampled_requests_enabled   = true
      }



      and_statement = {
        statements = [
          {
            byte_match_statement = {
              field_to_match = {
                uri_path = "{}"
              }
              positional_constraint = "EXACTLY"
              search_string         = "/sitemap.xml"
              priority              = 0
              type                  = "NONE"
            }
          },
          {
            byte_match_statement = {
              field_to_match = {
                uri_path = "{}"
              }
              positional_constraint = "EXACTLY"
              search_string         = "/robots.txt"
              priority              = 0
              type                  = "NONE"
            }
          }
        ]
      }
    },
    {
      name     = "Whitelist-upload-xss-cross-site"
      priority = "5"
      action   = "block"
      and_statement = {
        statements = [
          {
            label_match_statement = {
              key   = "awswaf:managed:aws:core-rule-set:CrossSiteScripting_Body"
              scope = "LABEL"
            }
          },
          {
            label_match_statement = {
              key   = "awswaf:managed:aws:core-rule-set:SizeRestrictions_Body"
              scope = "LABEL"
            }
          },
          {
            label_match_statement = {
              key   = "awswaf:managed:aws:sql-database:SQLi_Body"
              scope = "LABEL"
            }
          },
          {
            not_statement = {
              byte_match_statement = {
                field_to_match = {
                  uri_path = "{}"
                }
                positional_constraint = "CONTAINS"
                search_string         = "/admin/messages/uploadAttachments"
                priority              = 0
                type                  = "NONE"
              }
            }
          }
        ]
      }

      visibility_config = {
        cloudwatch_metrics_enabled = true
        sampled_requests_enabled   = true
        metric_name                = "Whitelist-upload-xss-cross-site-metric"
      }
    },
    {
      name     = "Magic-link-rate-limit"
      priority = "6"
      action   = "block"

      rate_based_statement = {
        limit              = 100
        aggregate_key_type = "IP"

        scope_down_statement = {
          byte_match_statement = {
            field_to_match = {
              uri_path = "{}"
            }
            positional_constraint = "STARTS_WITH"
            search_string         = "/admin/login/sendMagicLink"
            priority              = 0
            type                  = "NONE"
          }

        }
      }

      visibility_config = {
        cloudwatch_metrics_enabled = true
        sampled_requests_enabled   = true
        metric_name                = "Magic-link-rate-limit-metric"
      }
    }
  ]

  tags = merge(
    { Name = include.root.locals.resource_name },
    include.root.locals.base_tags
  )

}
