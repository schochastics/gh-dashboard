library(gh)
library(rvest)
repos <- read.csv("repos.csv", row.names = NULL)
get_repo <- function(owner, repo) {
    res_issues <- gh("/repos/{username}/{repo}/issues", username = owner, repo = repo)
    if (length(res_issues) != 0) {
        last_activity <- max(sapply(res_issues, \(x) x[["updated_at"]]))
    } else {
        last_activity <- ""
    }

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

# get CRAN status
url <- "https://cran.r-project.org/web/checks/check_summary_by_package.html"
doc <- read_html(url)
tab <- html_table(doc)[[1]]
me <- tab[tab$Package %in% repos$repo, -c(2, 16, 17)]
write.csv(me, "cran_status.csv", row.names = FALSE)
