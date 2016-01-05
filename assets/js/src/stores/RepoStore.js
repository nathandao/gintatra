import _ from 'lodash';

import control from 'control';
import RepoActions from 'actions/RepoActions';

class RepoStore {
  constructor() {
    this.bindActions(RepoActions);
    this.state = {
      repos: [],
      commitsOverviews: [],
      commitsData: [],
    };
  }

  onLoadRepoList(repos) {
    _.forEach(repos, (repo, index) => {
      repos[index].visible = true;
    });
    this.setState({
      repos,
    });
  }

  onSwitchRepoVisibility(repoId) {
    let repos = this.state.repos;
    let repoIndex = _.findIndex(repos, (repo) => {
      return repo.id === repoId;
    });

    if (repoIndex >= 0) {
      repos[repoIndex].visible = !repos[repoIndex].visible;
      this.setState({
        repos,
      });
    }
  }

  onLoadCommitsOverview(data) {
    let overviews = this.state.commitsOverviews;
    let repoIndex = _.findIndex(overviews, (overview) => {
      return overview.repoId === data.repoId;
    });

    if (repoIndex >= 0) {
      overviews[repoIndex] = data;
    } else {
      overviews.push(data);
    }
    this.setState({
      commitsOverviews: overviews,
    });
  }

  onLoadCommits(allCommitsData) {
    let commitsData = this.state.commitsData;
    _.forEach(allCommitsData, (data) => {
      let repoIndex = _.findIndex(commitsData, (commitData) => {
        return commitData.repoId === data.repoId;
      });

      if (repoIndex >= 0) {
        commitsData[repoIndex].commits = _.uniq(_.merge(
          commitsData[repoIndex].commits,
          data.commits
        ));
      } else {
        commitsData.push(data);
      }
    });
    this.setState({ commitsData });
  }
}

export default control.createStore(RepoStore, 'RepoStore');
