class ApplicationsController < ApplicationController
  before_action :set_application, only: [:edit, :update, :destroy]

  def new
  end

  def create
    @application = Doorkeeper::Application.new(application_params[:doorkeeper_application])
    @application.owner = current_user if Doorkeeper.configuration.confirm_application_owner?
    if @application.save
      redirect_to settings_path, notice: 'Application created! :)'
    else
      error_text = @application.errors.full_messages.to_sentence
      redirect_to new_application_path, alert: ":( Failed to create application: #{error_text.chomp('.')}."
    end
  end

  def edit
    if cannot?(:edit, @application)
      render :forbidden, status: 403
      return
    end
  end

  def update
    if cannot?(:edit, @application)
      render :forbidden, status: 403
      return
    end

    if params[:reset_secret] == '1'
      if @application.update(
        secret: Doorkeeper::OAuth::Helpers::UniqueToken.generate,
        secret_generated_at: Time.now
      )
        redirect_to(application_path(@application), notice: "Secret reset! :O Don't lose it this time!")
      else
        error_text = @application.errors.full_messages.to_sentence
        redirect_to application_path(@application), alert: ":( Failed to reset secret: #{error_text.chomp('.')}."
      end
      return
    end

    if @application.update(application_params[:doorkeeper_application])
      redirect_to(application_path(@application), notice: "Application saved! :D")
    else
      error_text = @application.errors.full_messages.to_sentence
      redirect_to application_path(@application), alert: ":( Failed to update application: #{error_text.chomp('.')}."
    end
  end

  def destroy
    if cannot?(:destroy, @application)
      render :forbidden, status: 403
      return
    end

    @application.destroy
    redirect_to(settings_path, notice: "#{@application.name} deleted.")
  end

  private

  def set_application
    @application = Doorkeeper::Application.find(params[:application])
  end

  def application_params
    params.permit(doorkeeper_application: [:name, :redirect_uri])
  end
end
