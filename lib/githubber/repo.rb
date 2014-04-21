module Githubber
  module Repo
    extend ActiveSupport::Concern

    def repos
      github_api.repos.all(per_page: 10000)
    end

    def stats(handle, repo_name)

      prs_by_user = {}
      number_of_prs_by_user = {}
      unique_commenters_by_user = {}
      number_of_mentions = {}
      mentions_by_user = {}
      total_prs = 0;

      possible_repos(handle, repo_name).each do |h, r|
        puts h + "/" + r
        all_pull_requests(h, r).each do |pr|
          total_prs = total_prs + 1
          user = pr.user.login
          puts total_prs.to_s + ") " + pr.title + ", by: " + user
          prs_by_user[user] = {} unless prs_by_user[user]

          num_prs = number_of_prs_by_user[user] || 0
          number_of_prs_by_user[user] = num_prs + 1

          commenters = Set.new
          comments_for_pr(pr.number, h, r).each do |comment|
            commenting_user = comment.user.login
            # puts "  comment by: " + commenting_user
            commenters.add(commenting_user)
            existing_comments = prs_by_user[user][commenting_user] || 0
            prs_by_user[user][commenting_user] = existing_comments + 1

            # find mentions in comment
            users = comment.body.scan(/\@[a-z0-9_-]*/)
            users.each do |pinged_user|
              pinged_user[0] = ''
              # puts "    mention of: " + pinged_user
              num_mentions = number_of_mentions[pinged_user] || 0
              number_of_mentions[pinged_user] = num_mentions + 1

              mentions_by_user[commenting_user] = {} unless mentions_by_user[commenting_user]
              num_of_pings = mentions_by_user[commenting_user][pinged_user] || 0
              mentions_by_user[commenting_user][pinged_user] = num_of_pings + 1
            end
          end

          commenters.each do |commenter|
            unique_commenters = unique_commenters_by_user[user] || {}
            previous_num = unique_commenters[commenter] || 0
            unique_commenters[commenter] = previous_num + 1

            unique_commenters_by_user[user] = unique_commenters
          end
        end
      end

      {
        comments_for_user: prs_by_user,
        number_of_prs_by_user: number_of_prs_by_user,
        unique_commenters_by_user: unique_commenters_by_user,
        number_of_mentions: number_of_mentions,
        mentions_by_user: mentions_by_user,
        total_prs: total_prs
      }
    end

    def possible_repos(handle, repo_name)
      names = [[handle, repo_name]]
      parent = github_api.repos.find(handle, repo_name).body.parent
      if parent
        names << [parent.owner.login, parent.name]
      end

      names
    end

    def all_pull_requests(handle, repo_name)
      all_prs = []
      github_api.pull_requests.list(handle, repo_name, state: 'closed', per_page: 100).each_page do |page|
        all_prs.concat(page)
      end

      github_api.pull_requests.list(handle, repo_name, state: 'open', per_page: 100).each_page do |page|
        all_prs.concat(page)
      end

      all_prs
    end

    def comments_for_pr(pr_number, handle, repo)
      all_comments = []
      github_api.pull_requests.comments.list(handle, repo, request_id: pr_number, per_page: 100).each_page do |page|
        all_comments.concat(page)
      end

      github_api.issues.comments.list(handle, repo, issue_id: pr_number, per_page: 100).each_page do |page|
        all_comments.concat(page)
      end

      all_comments
    end
  end
end
