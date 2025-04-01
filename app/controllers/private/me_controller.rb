module Private
  class MeController < Private::PrivateController
    skip_before_action :check_subscription, only: :me

    def me
      render json: @current_account, serializer: AccountSerializer, status: :ok
    end
  end
end
