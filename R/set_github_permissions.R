library(usethis)
use_git_config(user.name = "YOUR_USER_NAME",
               user.email = "YOUR_EMAIL")
git_vaccinate()
create_github_token()
gitcreds::gitcreds_set()
usethis::git_sitrep()
