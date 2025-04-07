resource "github_repository" "bootstrap_runners" {
  name                 = "atn-devops-runners"
  description          = "This is repository for bootstrap runners"
  auto_init            = true
  visibility           = "public"
  allow_update_branch  = true
  allow_merge_commit   = true
  allow_rebase_merge   = false
  vulnerability_alerts = true
}

resource "github_repository_file" "cd" {
  repository          = github_repository.bootstrap_runners.name
  file                = ".github/workflows/cd.yaml"
  content             = file("${path.module}/templates/workflows/cd-template.yaml")
  commit_author       = local.default_commit_email
  commit_email        = local.default_commit_email
  commit_message      = "Add cd [skip ci]"
  overwrite_on_create = true
}

resource "github_repository_file" "ci" {
  repository          = github_repository.bootstrap_runners.name
  file                = ".github/workflows/ci.yaml"
  content             = file("${path.module}/templates/workflows/ci-template.yaml")
  commit_author       = local.default_commit_email
  commit_email        = local.default_commit_email
  commit_message      = "Add cd [skip ci]"
  overwrite_on_create = true
}

# resource "github_branch_protection" "alz_templates" {
#   repository_id                   = github_repository.bootstrap_runners.name
#   pattern                         = "main"
#   enforce_admins                  = true
#   required_linear_history         = true
#   require_conversation_resolution = true

#   required_pull_request_reviews {
#     dismiss_stale_reviews           = true
#     restrict_dismissals             = true
#     required_approving_review_count = length(var.approvers) > 1 ? 1 : 0
#   }
# }
