# frozen_string_literal: true

require 'uffizzi/clients/api/api_client'

class ClusterService
  CLUSTER_STATE_DEPLOYING_NAMESPACE = 'deploying_namespace'
  CLUSTER_STATE_DEPLOYING = 'deploying'
  CLUSTER_STATE_DEPLOYED = 'deployed'
  CLUSTER_STATE_FAILED_DEPLOY_NAMESPACE = 'failed_deploy_namespace'
  CLUSTER_STATE_FAILED = 'failed'

  class << self
    include ApiClient

    def deployed?(cluster_state)
      cluster_state == CLUSTER_STATE_DEPLOYED
    end

    def deploying?(cluster_state)
      [CLUSTER_STATE_DEPLOYING_NAMESPACE, CLUSTER_STATE_DEPLOYING].include?(cluster_state)
    end

    def failed?(cluster_state)
      [CLUSTER_STATE_FAILED_DEPLOY_NAMESPACE, CLUSTER_STATE_FAILED].include?(cluster_state)
    end

    def wait_cluster_deploy(project_slug, cluster_name)
      spinner = TTY::Spinner.new("[:spinner] Creating cluster #{cluster_name}...", format: :dots)
      spinner.auto_spin

      loop do
        response = get_cluster(Uffizzi::ConfigFile.read_option(:server), project_slug, cluster_name)
        return Uffizzi::ResponseHelper.handle_failed_response(response) unless Uffizzi::ResponseHelper.ok?(response)

        cluster_data = response.dig(:body, :cluster)

        unless deploying?(cluster_data[:state])
          spinner.success
          return cluster_data
        end

        sleep(5)
      end
    end

    def generate_name
      name = [Faker::Name.first_name, Faker::Name.last_name].map(&:downcase).join('-')

      return name if valid_name?(name)

      generate_name
    end

    def valid_name?(name)
      return false if name.nil?

      regex = /\A[a-zA-Z0-9-]*\z/
      regex.match?(name)
    end
  end
end
