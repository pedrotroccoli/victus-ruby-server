class HabitsCheckController < ApplicationController
  before_action :authorize_request
  before_action :get_habit, only: [:index, :create, :update]

  def all
    habit_checks = HabitCheck.where(account_id: @current_account[:id])

    render json: habit_checks
  end

  def index
    habit_checks = @habit.habit_checks

    render json: habit_checks
  end

  def update
    habit_check = @habit.habit_checks.find(params[:check_id])

    habit_check.checked = !habit_check.checked

    habit_check.save!

    render json: habit_check, status: :ok
  end

  def create
     today_start = Time.current.beginning_of_day
     today_end = Time.current.end_of_day
     already_checked = @habit.habit_checks.where(account_id: @current_account[:id])
                                          .where(:finished_at.gte => today_start, :finished_at.lte => today_end)
                                          .first

     if already_checked.present?
       render json: { error: 'Already checked today' }, status: :unprocessable_entity
       return
     end

     habit_check = @habit.habit_checks.new(finished_at: Time.current, checked: true)
     habit_check.account_id = @current_account[:id]

     habit_check.save

     render json: habit_check, status: :created
  end

  private

  def get_habit
    @habit = Habit.where(account_id: @current_account[:id]).find(params[:habit_id].to_s)

    render json: { error: 'Habit not found' }, status: :not_found if @habit.nil?
  end
end