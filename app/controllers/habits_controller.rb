class HabitsController < ApplicationController
  before_action :authorize_request
  before_action :set_habit, only: [:show, :update, :destroy]

  def show
    render json: @habit
  end

  def index
    week_days = 7

    start_date = DateInternal.parse(params[:start_date], Date.today - week_days)
    end_date = DateInternal.parse(params[:end_date], Date.today + week_days)

    habits_from_account = Habit.where(account_id: @current_account[:id]).includes(:habit_category)

    @habits = habits_from_account
      .where(:$or => [
        { :start_date => { :$gte => start_date, :$lte => end_date } },
        { :end_date => nil },
        { :end_date => { :$gte => start_date, :$lte => end_date } }
      ])
      .order_by(:order.asc)

    render json: @habits.as_json(include: :habit_category)
  end

  def update
    @habit.update(update_params)

    render json: @habit, include: :habit_category, status: :ok
  end

  def create
    habit = Habit.new(habit_params)
    habit.account_id = @current_account[:id]

    habit.save!

    render json: habit
  rescue => e
    render json: { error: e.message }, status: :unprocessable_entity
  end

  def destroy
    @habit.destroy

    render json: { message: 'Hábito deletado com sucesso' }, status: :ok
  rescue => e
    render json: { error: e.message }, status: :unprocessable_entity
  end

  private

  def set_habit
    @habit = Habit.where(account_id: @current_account[:id]).find(params[:id])
  end

  def habit_params
    params.require(:habit).permit(:name, :description, :start_date, :end_date, :recurrence_type, recurrence_details: [:rule])
  end

  def update_params
    params.require(:habit).permit(:order, :name, :habit_category_id)
  end
end
