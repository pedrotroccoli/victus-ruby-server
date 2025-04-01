class Private::MoodController < Private::PrivateController
  def index
    render json: { message: 'Mood area' }, status: :ok
  end
end
