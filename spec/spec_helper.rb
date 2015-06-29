require 'rspec'
require 'rack/test'
require 'sinatra'
require 'fileutils'

require_relative '../lib/ginatra.rb'

module Ginatra
  class App < Sinatra::Base
    set :environment, :test
    set :data, Ginatra::Env.data || ::File.expand_path('../../test/dummy/data/', ::File.dirname(__FILE__))
  end
end

module GinatraSpecHelper
  DUMMY_DIR = File.expand_path('../test/dummy', File.dirname(__FILE__))
  REPOS_DIR = File.expand_path('repos/', GinatraSpecHelper::DUMMY_DIR)
  REPOS = %w{ git@github.com:nathandao/ginatra_dummy_1.git
              git@github.com:nathandao/ginatra_dummy_2.git }

  def create_test_dummy
    unless dummy_exists?
      create_dummy_directory
      pull_dummy_repos
      create_config_yml
    end
  end

  def destroy_test_dummy
    unless dummy_exists?
      remove_dummy_directory
    end
  end

  private

  def dummy_exists?
    File.directory?(GinatraSpecHelper::DUMMY_DIR)
  end

  def pull_dummy_repos
    GinatraSpecHelper::REPOS.each_with_index do |repo, i|
      `git clone #{repo} #{GinatraSpecHelper::REPOS_DIR}/repo_#{i}`
    end
  end

  def create_config_yml
    puts config_yml_content
    File.open(File.expand_path('./config.yml', GinatraSpecHelper::DUMMY_DIR), 'w') { |f|
      f.write(config_yml_content)
    }
  end

  def config_yml_content
    "
repositories:
  repo_1:
    path: #{GinatraSpecHelper::REPOS_DIR}/repo_1
    name: First Repository
  repo_2:
    path: #{GinatraSpecHelper::REPOS_DIR}/repo_2
    name: Second Repository

colors: ['#ce0000','#114b5f','#f7d708','#028090','#9ccf31','#ff9e00','#e4fde1','#456990','#ff9e00','#f45b69']

threshold: 3
sprint:
  period: 14
  reference_date: 3 June 2015
"
  end

  def create_dummy_directory
    FileUtils.mkdir_p(GinatraSpecHelper::DUMMY_DIR)
  end

  def remove_dummy_directory
    FileUtils.rm_r(GinatraSpecHelper::DUMMY_DIR)
  end
end

RSpec.configure do |config|
  config.include(GinatraSpecHelper)
end

module RequestSpecHelper
  shared_context "dummy test app" do
    before(:each) do
      Ginatra::App.root = GinatraSpecHelper::DUMMY_DIR
      Ginatra::App.data = GinatraSpecHelper::DUMMY_DIR + '/data'
      create_test_dummy
    end

    after(:each) do
      destroy_test_dummy
    end
  end
end
