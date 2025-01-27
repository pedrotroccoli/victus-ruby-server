class HabitsController < ApplicationController
  before_action :authorize_request

  def show
    @habit = Habit.where(account_id: @current_account[:id]).find(params[:id])

    render json: @habit
  end

  def index
    week_days = 7

    start_date = DateInternal.parse(params[:start_date], Date.today - week_days)
    end_date = DateInternal.parse(params[:end_date], Date.today + week_days)

    @habits = Habit.where(account_id: @current_account[:id]).where(start_date: start_date..end_date, end_date: start_date..end_date)

    render json: @habits
  end

  def update
    @habit = Habit.where(account_id: @current_account[:id]).find(params[:id])

    @habit.update!(update_params)

    render json: @habit, status: :ok
  end

  def create
    habit = Habit.new(habit_params)
    habit.account_id = @current_account[:id]

    habit.save!

    render json: habit
  rescue => e
    render json: { error: e.message }, status: :unprocessable_entity
  end
  private

  def habit_params
    params.require(:habit).permit(:name, :description, :start_date, :end_date, :recurrence_type, recurrence_details: [:rule])
  end

  def update_params
    params.require(:habit).permit(:order, :name)
  end
end
