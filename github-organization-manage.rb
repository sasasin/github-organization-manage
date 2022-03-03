#!/usr/bin/env ruby
require 'octokit'
require 'thor'
require 'pp'
require 'yaml'
require 'net/http'
require 'uri'
require 'json'

module GithubTeamManage
  class CUI < Thor

    desc "get_client", "internal method for this cli program"
    def get_client
      Octokit.configure do |c|
        c.access_token = ENV['GITHUB_ACCESS_TOKEN']
        c.auto_paginate = true
      end
      Octokit::Client.new
    end

    desc "org_repos", "List organization repositories"
    def org_repos
      get_client.org_repos(ENV['GITHUB_ORG_NAME']).each do |repo|
        puts "#{repo[:full_name]},#{repo[:private]},#{repo[:archived]}"
      end
    end

    desc "org_members", "Get organization members"
    def org_members
      get_client.org_members(ENV['GITHUB_ORG_NAME'], {"role":"admin"}).each do |member|
        puts "#{member[:login]},owner"
      end
      get_client.org_members(ENV['GITHUB_ORG_NAME'], {"role":"member"}).each do |member|
        puts "#{member[:login]},member"
      end
    end

    desc "org_collabs", "Get organization collaborators"
    def org_collabs
      uri = URI.parse("https://api.github.com/orgs/#{ENV['GITHUB_ORG_NAME']}/outside_collaborators")
      request = Net::HTTP::Get.new(uri)
      request["Authorization"] = "token #{ENV['GITHUB_ACCESS_TOKEN']}"
      req_options = {
        use_ssl: uri.scheme == "https",
      }
      response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
        http.request(request)
      end
      collaborators = JSON.parse(response.body)
      collaborators.each do |collaborator|
        puts collaborator["login"]
      end
    end

    desc "org_teams", "Get organization teams"
    def org_teams
      get_client.org_teams(ENV['GITHUB_ORG_NAME']).each do |team|
        puts "#{team[:name]},#{team[:id]}"
      end
    end

    desc "team_members", "List team members"
    def team_members
      client = get_client
      client.org_teams(ENV['GITHUB_ORG_NAME']).each do |team|
        client.team_members(team[:id]).each do |member|
          puts "#{team[:name]},#{member[:login]}"
        end
      end
    end

    desc "repos_member_permission", "listup who have permissions to repositories?"
    def repos_member_permission
      client = get_client
      client.org_repos(ENV['GITHUB_ORG_NAME']).each do |repo|
        client.collaborators(repo[:full_name]).each do |member|
          # 3個のbooleanを持っていて、下記のようにtrue/falseがついている。
          # Readl は admin:false, push:false, pull:true
          # Write は admin:false, push:true, pull:true
          # Admin は admin:true, push:true, pull:true
          permission = "Read" if member[:permissions][:pull]
          permission = "Write" if member[:permissions][:push]
          permission = "Admin" if member[:permissions][:admin]
          puts "#{repo[:full_name]},#{member[:login]},#{permission}"
        end
      end
    end

    desc "repos_team_permission", "listup what team have permissions to repositories?"
    def repos_team_permission
      client = get_client
      client.org_teams(ENV['GITHUB_ORG_NAME']).each do |team|
        client.team_repos(team[:id]).each do |repo|
          permission = "Read" if repo[:permissions][:pull]
          permission = "Write" if repo[:permissions][:push]
          permission = "Admin" if repo[:permissions][:admin]
          puts "#{repo[:full_name]},#{team[:name]},#{permission}"
        end
      end
    end

    desc "repos_collabs_permission", "listup collaborators have permissions to repositories"
    def repos_collabs_permission
      client = get_client
      client.org_repos(ENV['GITHUB_ORG_NAME']).each do |repo|
        client.collaborators(repo[:full_name], {"affiliation":"direct"}).each do |collaborator|
          permission = "Read" if collaborator[:permissions][:pull]
          permission = "Write" if collaborator[:permissions][:push]
          permission = "Admin" if collaborator[:permissions][:admin]
          puts "#{repo[:full_name]},#{collaborator[:login]},#{permission}"
        end
      end
    end

  end
end

GithubTeamManage::CUI.start
