class AuthController < ApplicationController
  before_action :authorize_request, only: :me

  def test
    render json: { message: ENV['JWT_SECRET'] }, status: :ok
  end

  def me
    render json: @current_account, serializer: AccountSerializer, status: :ok
  end

  def sign_in
    account = Account.find_by(email: params[:email])

    if account && account.authenticate(params[:password])
      token = JWT.encode({ account_id: account.id }, ENV['JWT_SECRET'], 'HS256')

      render json: { message: 'Signed in successfully', token: token }, status: :ok
    else
      render json: { message: 'Invalid email or password' }, status: :unauthorized
    end
  end

  def sign_up
    accounts_params = params.require(:account).permit(:email, :password, :name)

    already_exists = Account.find_by(email: accounts_params[:email])

    return render json: { message: 'Account already exists' }, status: :unauthorized if already_exists

    account = Account.new(accounts_params)

    if account.save
      token = JWT.encode({ account_id: account.id }, ENV['JWT_SECRET'], 'HS256')

      render json: { token: token, message: 'Signed up successfully' }, status: :ok
    else
      render json: { message: 'Invalid email or password' }, status: :unauthorized
    end
  end
end
