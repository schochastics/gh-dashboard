library(gh)

repos <- read.csv("repos.csv", row.names = NULL)
get_repo <- function(owner, repo) {
    res_issues <- gh("/repos/{username}/{repo}/issues", username = owner, repo = repo)
    last_activity <- max(sapply(res_issues, \(x) x[["updated_at"]]))

    res_repo <- gh("/repos/{username}/{repo}", username = owner, repo = repo)
    data.frame(
        owner = owner,
        repo = repo,
        last_push = lubridate::as_datetime(res_repo[["pushed_at"]]),
        stars = res_repo[["stargazers_count"]],
        forks = res_repo[["forks"]],
        open_issues = res_repo[["open_issues_count"]],
        last_issue_activity = suppressWarnings(lubridate::as_datetime(last_activity))
    )
}

lst <- lapply(seq_len(nrow(repos)), \(x) {
    get_repo(repos$owner[x], repos$repo[x])
})

res <- do.call("rbind", lst)
write.csv(read.csv("current_week.csv", row.names = NULL), "last_week.csv", row.names = FALSE)
write.csv(res, "current_week.csv", row.names = FALSE)
