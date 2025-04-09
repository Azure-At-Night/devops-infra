resource "github_repository" "atn_test1_repoistory1" {
  name                 = "atn-test1-runners1"
  description          = "This is a test repository for testing purposes."
  auto_init            = true
  visibility           = "public"
  allow_update_branch  = true
  allow_merge_commit   = true
  allow_rebase_merge   = false
  vulnerability_alerts = true
}
