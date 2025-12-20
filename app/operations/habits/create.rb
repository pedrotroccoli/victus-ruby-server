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

      contract_result = Habits::CreateHabitContract.new.call(params.to_h)

      if contract_result.failure?
        ctx[:errors] << contract_result.errors
      end

      ctx[:errors].empty?
    end

    def build_habit(ctx, params:, account:, **)
      habit_params = params.except(:habit_deltas)

      ctx[:habit] = Habits::Habit.new(habit_params.merge(account_id: account.id.to_s))
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

