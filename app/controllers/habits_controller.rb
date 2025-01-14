class HabitsController < ApplicationController
  before_action :authorize_request

  def show
    @habit = Habit.where(account_id: @current_account[:id]).find(params[:id])

    render json: @habit
  end

  def index
    @habits = Habit.where(account_id: @current_account[:id])

    render json: @habits
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
    params.require(:habit).permit(:name, :description, :start_date, :end_date, :recurrency_type, :recurrency_details)
  end
end
