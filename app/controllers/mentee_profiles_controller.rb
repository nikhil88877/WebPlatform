class MenteeProfilesController < ApplicationController
  before_action :require_mentee, except: [ :show ]
  before_action :require_login, only: [:show]

  def show
    @user = User.find(params[:id])
    @mentor = User.find(@user.matched_id)
    @project = Project.find_by(mentee_id: params[:id])
  end

  def dashboard
    @mentor = User.find(current_user.matched_id)
    @project = Project.find_by(mentee_id: current_user.id)
    @tasks = Task.where(project_id: @project.id)

  end

  def edit
    @project = Project.find_by(mentee_id: current_user.id)
  end

  def update
    @project = Project.find_by(mentee_id: current_user.id)

    if current_user.update_attributes(user_params)
      @project.update_column :mentor_id, current_user.matched_id
      redirect_to mentee_profile_path, notice: "Details have been succesfuly updated."
    else
      render "edit"
    end
  end

  def missing_mentor
    @user = current_user
    @mentor = User.find(current_user.matched_id)
    if @mentor.update_attribute(:is_missing, true)
      MissingPersonsMailer.missing_mentor(@user).deliver_now
      redirect_to dashboard_mentee_profiles_path, notice: 'Organsiers Have been notified about the missing mentor'
    else
      redirect_to dashboard_mentee_profiles_path, notice: 'Couldnt send mail'
    end
  end

  private

  def user_params
    params.require(:user).permit(
      :first_name, :last_name, :country, :program_country, :timezone, :avatar,
      :project_attributes => [:id, :title,:language,:description,:github_link]
    )
  end
end
