resource "github_repository_environment" "alz" {
  depends_on  = [github_team_repository.alz]
  for_each    = local.environments
  environment = each.value.name
  repository  = github_repository.bootstrap_runners.name

  dynamic "reviewers" {
    for_each = each.key == length(local.approvers) > 0 ? [1] : []
    content {
      teams = [
        github_team.alz.id
      ]
    }
  }

  dynamic "deployment_branch_policy" {
    for_each = each.value.protected == true ? [1] : []
    content {
      protected_branches     = true
      custom_branch_policies = false
    }
  }
}
