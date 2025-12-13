require_relative '../../contracts/habits/create_habit'

module Habits
  class Create < Trailblazer::Operation
    step :validate_params
    step :build_habit
    step :assign_account
    step :build_habit_deltas
    step :save_habit

    def validate_params(ctx, params:, account:, **)
      ctx[:errors] = []

      unless account.present?
        ctx[:errors] << "Account is required"
        return false
      end

      params_with_account = params.merge(account_id: account.id.to_s)

      contract_result = CreateHabitContract.new.call(params_with_account)

      if contract_result.failure?
        ctx[:errors] << contract_result.errors
      end

      ctx[:errors].empty?
    end

    def build_habit(ctx, params:, **)
      habit_params = params.except(:habit_deltas)

      ctx[:habit] = Habit.new(habit_params)
    end

    def assign_account(ctx, account:, **)
      ctx[:habit].account = account
      true
    end

    def build_habit_deltas(ctx, params:, **)
      return true unless params[:habit_deltas].present?

      params[:habit_deltas].each do |delta_params|
        delta = HabitDelta.new(delta_params)
        ctx[:habit].habit_deltas << delta
      end

      true
    end

    def save_habit(ctx, **)
      if ctx[:habit].save
        true
      else
        ctx[:errors] << ctx[:habit].errors.full_messages
        false
      end
    end
  end
end

