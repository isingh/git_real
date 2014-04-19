module Githubber
  module Repo
    extend ActiveSupport::Concern

    @user = ""
    def repos
      github_api.repos.all(per_page: 10000)
    end

    def pull_requests(handle, repo_name)
      @user = handle
      prs = []
      possible_repos(handle, repo_name).each do |h, r|
        prs.concat(all_pull_requests(h,r))
      end
      puts prs.count
      prs
    end

    def possible_repos(handle, repo_name)
      names = [[handle, repo_name]]
      begin
        parent = github_api.repos.find(handle, repo_name).body.parent
        if parent
          names << [parent.owner.login, parent.name]
        end
      rescue
        puts "fail possible_repos"
      end
	  
      names
    end

    def all_pull_requests(handle, repo_name)
      all_prs = []
      begin
        github_api.pull_requests.list(handle, repo_name, state: 'closed', per_page: 100).each_page do |page|
          all_prs.concat(page)
        end
      rescue
        puts "fail all_pull_requests closed"
      end

      begin
        github_api.pull_requests.list(handle, repo_name, state: 'open', per_page: 100).each_page do |page|
          all_prs.concat(page)
        end
      rescue
        puts "fail all_pull_requests open"
      end

      all_prs
    end

    def all_my_pull_requests(handle, repo_name)
      all_prs = pull_requests(handle, repo_name)

      my_prs = []
      all_prs.each do |pr|
        if (pr.user.login == @user)
          my_prs.push(pr)
        end
      end
      puts my_prs.count
      my_prs
    end

    def all_comments_in_my_prs(handle, repo_name)
      all_my_prs = all_my_pull_requests(handle, repo_name)

      all_my_comments = []
      all_my_prs.each do |pr|
        comments = github_api.pull_requests.comments.list pr.base.repo.full_name.split("/")[0], repo_name, request_id: pr.number
        all_my_comments.concat(comments)
      end

      all_my_comments
    end

    def all_my_friends(handle, repo_name)
      @user = handle
      friends = []
      possible_repos(handle, repo_name).each do |h, r|
        collaborators = github_api.repos.collaborators.list(h, r)
        collaborators.each_page do |page|
          page.each do |collab|
            next if collab.login == @user
            if (!friends.include? collab.login)
              friends.push(collab.login)
            end
          end
        end
      end
      friends
    end

    def friend_scores(handle, repo_name)
      @user = handle
      all_my_comments = all_comments_in_my_prs(handle, repo_name)
      all_my_friends = all_my_friends(handle, repo_name)

      friend_scores = {}
      all_my_comments.each do |comment|
        if (all_my_friends.include? comment.user.login)
          if (friend_scores.has_key?(comment.user.login))
            friend_scores[comment.user.login] = friend_scores[comment.user.login] + 1
          else
            friend_scores[comment.user.login] = 1
          end
            puts comment.user.login + " - " + comment.body
        end
      end

      puts all_my_comments.count
      puts all_my_friends
      puts friend_scores
      friend_scores
    end

    def friend_scores2(handle, repo_name)
      @user = handle
      all_prs = pull_requests(handle, repo_name)
      all_my_friends = all_my_friends(handle, repo_name)

      friend_scores = {}

      all_prs.each do |pr|
        comments = github_api.pull_requests.comments.list pr.base.repo.full_name.split("/")[0], repo_name, request_id: pr.number
        comments.each do |comment|
          next if comment.user.login == @user
          if (all_my_friends.include? comment.user.login)
            if (friend_scores.has_key?(comment.user.login))
              friend_scores[comment.user.login] = friend_scores[comment.user.login] + 1
            else
              friend_scores[comment.user.login] = 1
            end
            puts comment.user.login + ': ' + pr.title + " - " + comment.body
          end
        end
      end

      puts all_my_friends
      puts friend_scores
      friend_scores
    end

    def friend_score(handle, repo_name, friend)
      @user = handle
      all_prs = all_my_pull_requests(handle, repo_name)

      current_friend_score = 0

      all_prs.each do |pr|
        comments = github_api.pull_requests.comments.list pr.base.repo.full_name.split("/")[0], repo_name, request_id: pr.number
        comments.each_page do |page|
          page.each do |comment|
            next if comment.user.login == @user
            if (friend == comment.user.login)
              puts comment.body
              current_friend_score += 1
            end
          end
        end
      end
      current_friend_score
    end

    def friend_scores3(handle, repo_name)
      friend_scores = friend_scores(handle, repo_name)

      final = {}

      friend_scores.each do |friend|
        final[friend[0]] = [friend[1], friend_score(friend[0].to_s, repo_name, handle)]
      end

      final
    end
  end
end
