resource "github_actions_runner_group" "alz" {
  name                    = "atn-devops-runners"
  visibility              = "selected"
  selected_repository_ids = [github_repository.bootstrap_runners.repo_id]
}
