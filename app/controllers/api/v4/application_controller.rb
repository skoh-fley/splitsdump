class Api::V4::ApplicationController < ActionController::Base
  include Rails::Pagination

  skip_before_action :set_browser_id
  skip_before_action :touch_auth_session
  before_action :read_only_mode, if: -> { ENV['READ_ONLY_MODE'] == '1' }

  def options
    headers['Allow'] = 'POST, PUT, DELETE, GET, OPTIONS'
  end

  def read_only_mode
    write_actions = %w[create edit destroy].freeze
    write_methods = %w[POST PUT DELETE PATCH].freeze
    return unless write_actions.include?(action_name) || write_methods.include?(request.method)

    render template: 'pages/read_only_mode'
  end

  private

  # override authie's current_user methods for API, so we don't set or obey cookies
  attr_accessor :current_user

  def build_link_headers(links)
    links.map do |link|
      "<#{link[:url]}>; rel=\"#{link[:rel]}\""
    end.join(', ')
  end

  def not_found(collection_name)
    {
      status: :not_found,
      json:   {
        status: 404,
        error:  "No #{collection_name} with ID #{params[collection_name]} found."
      }
    }
  end

  def set_category
    @category = Category.find(params[:category])
  rescue ActiveRecord::RecordNotFound
    render not_found(:category)
  end

  def set_game
    @game = Game.joins(:srdc).find_by!(speedrun_dot_com_games: {shortname: params[:game]})
  rescue ActiveRecord::RecordNotFound
    render not_found(:game)
  end

  def set_runner
    @runner = User.with_runs.find_by!(name: params[:runner])
  rescue ActiveRecord::RecordNotFound
    render not_found(:runner)
  end

  def set_run
    @run = if params[:historic] == '1'
             Run.includes(:game, :category, :user, :histories, segments: [:histories]).find36(params[:run])
           else
             Run.includes(:game, :category, :user, :segments).find36(params[:run])
           end
  rescue ActiveRecord::RecordNotFound
    render not_found(:run)
  end

  def verify_ownership!
    if params[:claim_token].blank?
      head 401
    elsif params[:claim_token] != @run.claim_token
      head 403
    end
  end

  def set_user
    if request.headers['Authorization'].present? || params[:access_token].present?
      doorkeeper_authorize!(:manage_race)
      self.current_user = User.find(doorkeeper_token.resource_owner_id) if doorkeeper_token
    end

    head :unauthorized if current_user.nil?
  rescue ActiveRecord::RecordNotFound
    head :unauthorized
  end

  def set_raceable(klass) # rubocop:disable Naming/AccessorMethodName
    @raceable = klass.find(params[:raceable])
    return unless @raceable.secret_visibility? && !@raceable.joinable?(user: current_user, token: params[:join_token])

    render status: :forbidden, json: {
      status: 403,
      error:  'Must be invited to see this race'
    }
  rescue ActiveRecord::RecordNotFound
    render not_found(klass.type)
  end
end
