resource "github_team" "alz" {
  name        = "atn-team"
  description = "Approvers for the Landing Zone Terraform Apply"
  privacy     = "closed"
}

resource "github_team_membership" "alz" {
  for_each = { for approver in local.approvers : approver => approver }
  team_id  = github_team.alz.id
  username = each.key
  role     = "member"
}

resource "github_team_repository" "alz" {
  team_id    = github_team.alz.id
  repository = github_repository.bootstrap_runners.name
  permission = "push"
}
