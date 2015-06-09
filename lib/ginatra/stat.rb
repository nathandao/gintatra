module Ginatra
  class Stat
    class << self
      def commits params = {}
        if params[:in].nil?
          repos = Ginatra::Config.repositories
          repos.inject({}) { |output, repo|
            repo_id = repo[0]
            output[repo_id] = Ginatra::Helper.get_repo(repo_id).commits params
            output
          }
        else
          { params[:in] => Ginatra::Helper.get_repo(params[:in]).commits(params) }
        end
      end

      def commits_count params = {}
        commits_count = nil
        if params[:in].nil?
          repos = Ginatra::Config.repositories
          commits_count = repos.inject(0) { |count, repo|
            repo_id = repo[0]
            count += Ginatra::Helper.get_repo(repo_id).commits(params).size
            count
          }
        else
          repo_id = params[:in]
          commits_count = Ginatra::Helper.get_repo(repo_id).commits(params).size
        end
        return commits_count.nil? ? 0 : commits_count
      end

      def commits_overview params = {}
        commits_count = 0
        additions = 0
        deletions = 0
        commits(params).each do |repo_id, repo_commits|
          commits_count += repo_commits.size
          additions += Ginatra::Helper.get_additions(repo_commits)
          deletions += Ginatra::Helper.get_deletions(repo_commits)
        end
        return {commits_count: commits_count, additions: additions,
                deletions: deletions}
      end

      def authors params = {}
        if params[:in].nil?
          Ginatra::Config.repositories.inject([]) { |output, repo|
            repo_id = repo[0]
            authors = Ginatra::Helper.get_repo(repo_id).authors params
            authors.each do |author|
              match = output.select { |k, v| k == author['name'] }
              if match.empty?
                output << author
              else
                author.each do |k, v|
                  # TODO: fix this
                end
              end
            end
          }
        else
          Ginatra::Helper.get_repo(params[:in]).authors params
        end
      end

      def lines params = {}
        if params[:in].nil?
          repos = Ginatra::Config.repositories
          repos.inject({}) { |result, repo|
            repo_id = repo[0]
            result[repo_id] = Ginatra::Helper.get_repo(repo_id).lines params
            result
          }
        else
          Ginatra::Helper.get_repo(params[:in]).lines params
        end
      end

      def refresh_all_data
        repos = Ginatra::Config.repositories
        repos.each do |key, params|
          Ginatra::Helper.get_repo(key).refresh_data
        end
      end
    end
  end
end
