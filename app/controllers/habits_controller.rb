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
    if @habit.update(update_params)
      render json: @habit, include: :habit_category, status: :ok
    else
      render json: { errors: @habit.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def create
    create_params = habit_params

    habit = Habit.new(create_params.except(:habit_deltas))
    habit.account_id = @current_account[:id]

    if create_params[:habit_deltas].present?
      create_params[:habit_deltas].each do |delta|
        delta = HabitDelta.new(delta)
        habit.habit_deltas << delta
      end
    end

    if habit.save
      render json: habit, include: :habit_category, status: :created
    else
      render json: { errors: habit.errors.full_messages }, status: :unprocessable_entity
    end
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
    params.require(:habit).permit(
      :name, 
      :description, 
      :start_date, 
      :end_date, 
      :recurrence_type,
      :delta_enabled,
      habit_deltas: [:type, :name, :description, :enabled],
      recurrence_details: [:rule]
    )
  end

  def update_params
    params.require(:habit).permit(
      :order, 
      :name, 
      :habit_category_id, 
      :delta_enabled, 
      habit_deltas_attributes: [:id, :type, :name, :description, :enabled, :_destroy]
    )
  end
end
