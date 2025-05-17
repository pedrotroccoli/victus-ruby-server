module Private
  class MeController < Private::PrivateController
    skip_before_action :check_subscription, only: :me

    def me
      render json: @current_account, serializer: AccountSerializer, status: :ok
    end

    def update_me
      @current_account.update(account_params)
      render json: @current_account, serializer: AccountSerializer, status: :ok
    end

    private

    def account_params
      params.require(:account).permit(:name)
    end
    
  end
end
