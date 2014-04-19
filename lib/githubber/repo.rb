module Githubber
  module Repo
    extend ActiveSupport::Concern

    def repos
      github_api.repos.all(per_page: 10000)
    end

    def pull_requests(handle, repo_name)
      prs = []
      possible_repos(handle, repo_name).each do |h, r|
        prs.concat(all_pull_requests(h,r))
      end
      prs
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
  end
end
