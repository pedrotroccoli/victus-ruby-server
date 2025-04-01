monthly = Rails.env.production? ? 'victus_journal_monthly' : 'dev_victus_journal_monthly'
yearly = Rails.env.production? ? 'victus_journal_yearly' : 'dev_victus_journal_yearly'

    PLANS = [
      {
        name: 'Plano Mensal',
        key:  'dev_victus_journal_monthly',
        price: 'R$ 10,00',
        features: [
          {
            name: 'Criação de 50 hábitos',
          },
          {
            name: 'Criação de Deltas',
          },
          {
            name: 'Analytics avançado'
          },
          {
            name: 'Suporte via chat (Email)'
          }
        ]
      },
      {
        name: 'Plano Anual',
        key: 'dev_victus_journal_yearly',
        price: 'R$ 100,00',
        features: [
          {
            name: 'Criação de infinitos hábitos',
          },
          { 
            name: 'Criação de Deltas',
          },
          {
            name: 'Analytics avançado'
          },
          {
            name: 'Suporte via chat (Email e WhatsApp)'
          }
        ]
      }
    ]


class Private::PlansController < Private::PrivateController
  skip_before_action :check_subscription

  def index
    render json: PLANS, status: :ok
  end
end
