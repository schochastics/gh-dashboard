library(gh)
library(tibble)
repos <- readr::read_csv("repos.csv")
get_repo <- function(owner, repo) {
    res_issues <- gh("/repos/{username}/{repo}/issues", username = owner, repo = repo)
    res_repo <- gh("/repos/{username}/{repo}", username = owner, repo = repo)
    tibble(
        owner = owner,
        repo = repo,
        last_push = lubridate::as_datetime(res_repo[["pushed_at"]]),
        stars = res_repo[["stargazers_count"]],
        forks = res_repo[["forks"]],
        open_issues = res_repo[["open_issues_count"]],
        last_issue_activity = suppressWarnings(lubridate::as_datetime(max(purrr::map_chr(res_issues, \(x) x[["updated_at"]])))),
    )
}

repos <- readr::read_csv("repos.csv")
res <- purrr::map_dfr(seq_len(nrow(repos)), \(x){
    get_repo(repos$owner[x], repos$repo[x])
})

readr::write_csv(readr::read_csv("current_week.csv"), "last_week.csv")
readr::write_csv(res, "current_week.csv")
